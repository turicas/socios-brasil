import datetime
import re
from dataclasses import dataclass
from email.utils import parsedate_to_datetime
from pathlib import Path
from textwrap import dedent
from urllib.parse import unquote, urljoin, urlparse
from xml.etree import ElementTree as ET

import requests
from lxml.html import document_fromstring
from rows.utils.download import Download, Downloader


def parse_iso_date(value):
    """
    >>> print(parse_iso_date(""))
    None
    >>> print(parse_iso_date(None))
    None
    >>> print(parse_iso_date("2024-12-01"))
    datetime.date(2024, 12, 1)
    """
    value = str(value or "").strip()
    if not value:
        return None
    return datetime.datetime.strptime(value, "%Y-%m-%d").date()


@dataclass
class Link:
    is_folder: bool
    url: str
    filename: str
    updated_at: datetime.datetime
    size: float
    description: str = None


def apache_file_list(main_url, recursive=False):
    # TODO: add option to get filename from URL or <a>/text()
    main_path = Path(urlparse(main_url).path)
    links, htmls = [], []
    stack = [("index.html", main_url)]
    while stack:
        filename, listing_url = stack.pop(0)
        response = requests.get(listing_url)
        htmls.append((filename, response.text))
        tree = document_fromstring(response.text)
        for line in tree.xpath("//table//tr"):
            columns = line.xpath(".//td")
            if not columns:
                continue
            icon, name, last_modified, size, description = columns
            icon_filename = icon.xpath(".//img/@src")[0]
            if icon_filename.endswith("back.gif"):  # "Parent Directory" line
                continue
            size = size.xpath(".//text()")[0].strip()
            size = size if size != "-" else None
            if size is not None:
                if size.endswith("K"):
                    size = float(size[:-1]) * 1024
                elif size.endswith("M"):
                    size = float(size[:-1]) * 1024 * 1024
                elif size.endswith("G"):
                    size = float(size[:-1]) * 1024 * 1024 * 1024
            description = description.xpath(".//text()")[0].strip()
            link_url = urljoin(listing_url, name.xpath(".//a/@href")[0])
            is_folder = icon_filename.endswith("folder.gif")
            if not recursive or not is_folder:
                # filename = name.xpath(".//a/text()")[0].strip()  # XXX: not ideal
                filename = Path(unquote(urlparse(link_url).path)).name
                links.append(
                    Link(
                        is_folder=is_folder,
                        url=link_url,
                        filename=filename,
                        updated_at=datetime.datetime.fromisoformat(last_modified.xpath(".//text()")[0].strip() + ":00"),
                        size=size,
                        description=description or None,
                    )
                )
            else:
                relative = Path(urlparse(link_url).path).relative_to(main_path)
                stack.append((f"{str(relative).replace('/', '_')}.html", link_url))
    return links, htmls


class BaseReceitaFileFinder:

    def __init__(self, mirror=False):
        self.mirror = mirror

    def _fix_mirror_url(self, links, extraction_date):
        for link in links:
            if self.mirror:
                link.url = f"https://data.brasil.io/mirror/socios-brasil/{extraction_date}/{link.filename}"
            yield link

    @property
    def datas(self) -> list[datetime.date]:
        """Retorna datas de extração para as quais é possível baixar os dados"""
        # Cada pasta possui como nome o ano e o mês (YYYY-MM)
        resultado = []
        for link in self.pastas():
            if not link.is_folder:
                print(f"WARNING: encontrado arquivo na pasta raiz (não esperado): {link}")
                continue
            folder_name = Path(link.url).name
            if re.match("^[0-9]{4}-[0-9]{2}$", folder_name):
                resultado.append(parse_iso_date(f"{folder_name}-01"))
            else:
                print(f"WARNING: ignorando pasta que não é data: {repr(folder_name)}")
        return resultado


class ReceitaFileFinderApache(BaseReceitaFileFinder):
    url_arquivos_principais = "https://arquivos.receitafederal.gov.br/dados/cnpj/dados_abertos_cnpj/"
    url_regime_tributario = "https://arquivos.receitafederal.gov.br/dados/cnpj/regime_tributario/"

    def pastas(self):
        links, htmls = apache_file_list(self.url_arquivos_principais, recursive=False)
        links.sort(key=lambda link: link.filename, reverse=True)
        return links

    def links_arquivos_principais(self, data: datetime.date):
        """Lista de links para os arquivos principais (empresa, estabelecimento, sócio etc.)"""
        base_url = self.url_arquivos_principais
        url = base_url + ("/" if base_url[0] != "/" else "") + data.strftime("%Y-%m") + "/"
        links, htmls = apache_file_list(url, recursive=False)
        links.sort(key=lambda link: link.filename, reverse=True)
        return links

    def links_regime_tributario(self):
        """Lista de links para regime tributário"""
        links, htmls = apache_file_list(self.url_regime_tributario, recursive=True)
        links.sort(key=lambda link: link.updated_at, reverse=True)
        return links


class ReceitaFileFinderNextCloud(BaseReceitaFileFinder):
    """Lista arquivos disponíveis para baixar na instância do NextCloud da Receita Federal"""

    base_url = "https://arquivos.receitafederal.gov.br/public.php/dav/files/gn672Ad4CF8N6TK/"

    def lista_arquivos(self, pasta, depth=1):
        body = dedent("""
            <?xml version="1.0"?>
            <d:propfind xmlns:d="DAV:">
              <d:prop>
                <d:displayname/>
                <d:getcontentlength/>
                <d:getcontenttype/>
                <d:resourcetype/>
                <d:getlastmodified/>
              </d:prop>
            </d:propfind>
            """).strip()
        list_url = urljoin(self.base_url, pasta)
        headers = {"Depth": str(depth), "Content-Type": "application/xml"}
        response = requests.request(method="PROPFIND", url=list_url, headers=headers, data=body)
        response.raise_for_status()
        ns = {"d": "DAV:"}
        root = ET.fromstring(response.content)
        props_mapping = {"displayname": "filename", "getcontentlength": "size", "getlastmodified": "updated_at"}
        arquivos = []
        for item in root.findall("d:response", ns):
            href = item.find("d:href", ns).text
            props = item.find("d:propstat/d:prop", ns)
            link = {
                "url": urljoin(list_url, href),
                "is_folder": props.find("d:resourcetype/d:collection", ns) is not None,
            }
            if list_url.rstrip("/") == link["url"].rstrip("/"):
                continue
            for old_key, new_key in props_mapping.items():
                v = props.find(f"d:{old_key}", ns)
                link[new_key] = v.text if v is not None else None
                if new_key == "size" and link[new_key] is not None:
                    link[new_key] = int(link[new_key])
                elif new_key == "updated_at":
                    link[new_key] = parsedate_to_datetime(link[new_key])
            arquivos.append(Link(**link))
        return arquivos

    def pastas(self):
        links = self.lista_arquivos("Dados/Cadastros/CNPJ/")
        links.sort(key=lambda link: link.filename, reverse=True)
        return links

    def links_arquivos_principais(self, data: datetime.date):
        """Lista de links para os arquivos principais (empresa, estabelecimento, sócio etc.)"""
        links = self.lista_arquivos(f"Dados/Cadastros/CNPJ/{data.strftime('%Y-%m')}")
        links.sort(key=lambda link: link.filename, reverse=True)
        return links

    def links_regime_tributario(self):
        """Lista de links para regime tributário"""
        links = [
            link
            for link in self.lista_arquivos("Dados/Obrigacoes_Acessorias/ECF")
            if link.filename.lower().endswith(".zip")
        ]
        links.sort(key=lambda link: link.filename, reverse=True)
        return links


def main():
    import argparse
    import sys

    subclasses = Downloader.subclasses()
    parser = argparse.ArgumentParser()
    parser.add_argument("--date", "-d", type=parse_iso_date, help="Download for a specific date")
    parser.add_argument("--path-pattern", "-p", type=Path, default=Path("data/download/{date}/{filename}"))
    parser.add_argument("--downloader", "-D", type=str, choices=list(subclasses.keys()), default="aria2c")
    parser.add_argument("--mirror", "-m", action="store_true")
    args = parser.parse_args()
    data_selecionada = args.date
    path_pattern = str(args.path_pattern.absolute())

    receita = ReceitaFileFinderNextCloud(mirror=args.mirror)
    datas_disponiveis = list(receita.datas)
    if not data_selecionada:
        data_selecionada = datas_disponiveis[0]
    elif data_selecionada not in datas_disponiveis:
        disponiveis_str = ", ".join(map(str, datas_disponiveis))
        print(
            f"ERRO: data selecionada ({data_selecionada}) não é uma das disponíveis: {disponiveis_str}",
            file=sys.stderr,
        )
        exit(1)

    links_principais = list(receita.links_arquivos_principais(data_selecionada))
    datas_principais = set([link.updated_at.strftime("%Y-%m-%d") for link in links_principais])
    if len(datas_principais) == 1 and list(datas_principais)[0][:-3] == data_selecionada.strftime("%Y-%m"):
        data_principais = parse_iso_date(list(datas_principais)[0])
    else:
        data_principais = data_selecionada
    links_regime_tributario = list(receita.links_regime_tributario())
    if len(links_regime_tributario) > 0:
        data_regime_tributario = links_regime_tributario[0].updated_at.strftime("%Y-%m-%d")
    else:
        data_regime_tributario = None

    print(f"Data da última extração: {datas_disponiveis[0].strftime('%Y-%m')}")
    print(f"Baixando para data (arquivos principais): {data_selecionada}")
    print(f"Baixando para data (regime tributário): {data_regime_tributario}")

    downloads = []
    for link in links_principais:
        downloads.append(
            Download(
                url=link.url,
                filename=path_pattern.format(date=data_principais, filename=link.filename),
            )
        )
    for link in links_regime_tributario:
        downloads.append(
            Download(
                url=link.url,
                filename=path_pattern.format(
                    date=data_principais, filename=f"{data_regime_tributario}_{link.filename}"
                ),
            )
        )
    DownloaderClass = subclasses[args.downloader]
    kwargs = {}
    if DownloaderClass.__name__ == "Aria2cDownloader":
        kwargs["max_concurrent_downloads"] = 2
        kwargs["max_connections_per_download"] = 2
    downloader = DownloaderClass(max_tries=len(downloads) * 5, **kwargs)
    downloader.add_many(downloads)
    downloader.run()


if __name__ == "__main__":
    main()
