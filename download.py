import datetime
import json
from dataclasses import dataclass
from pathlib import Path
from urllib.parse import unquote, urljoin, urlparse, urlsplit

import requests
from lxml.html import document_fromstring
from rows.utils.download import Download, Downloader


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


class ReceitaFileFinder:
    ckan_url = "https://dados.gov.br/api/publico/conjuntos-dados/cadastro-nacional-da-pessoa-jurdica---cnpj"
    apache_list_url = "https://dadosabertos.rfb.gov.br/CNPJ/"

    def __init__(self, mirror=False):
        self.mirror = mirror

    def _fix_mirror_url(self, links, extraction_date):
        for link in links:
            if self.mirror:
                link.url = f"https://data.brasil.io/mirror/socios-brasil/{extraction_date}/{link.filename}"
            yield link

    @property
    def apache_links(self):
        links, self.apache_htmls = list(apache_file_list(self.apache_list_url, recursive=True))
        self.apache_extraction_date = max(link.updated_at for link in links).date()
        yield from self._fix_mirror_url(links, self.apache_extraction_date)

    @property
    def ckan_links(self):
        response = requests.get(self.ckan_url)
        data = self.ckan_json = response.json()
        links = []
        for resource in data["resources"]:
            links.append(
                Link(
                    is_folder=False,
                    url=resource["url"],
                    filename=Path(urlsplit(resource["url"]).path).name,
                    updated_at=datetime.datetime.fromisoformat(resource["created"].split(".")[0]),
                    size=resource["size"],
                    description=resource["description"],
                )
            )
        self.ckan_extraction_date = max(link.updated_at for link in links).date()
        yield from self._fix_mirror_url(links, self.ckan_extraction_date)


def main():
    import argparse

    subclasses = Downloader.subclasses()
    parser = argparse.ArgumentParser()
    parser.add_argument("--path-pattern", default="data/download/{date}/{filename}")
    parser.add_argument("--downloader", choices=list(subclasses.keys()), default="aria2c")
    parser.add_argument("--mirror", action="store_true")
    args = parser.parse_args()

    receita = ReceitaFileFinder(mirror=args.mirror)
    apache_links = list(receita.apache_links)  # TODO: add option to choose between apache and ckan
    ckan_links = list(receita.ckan_links)  # TODO: add option to choose between apache and ckan
    extraction_date = receita.apache_extraction_date  # TODO: add option to choose between apache and ckan
    date = extraction_date.strftime("%Y-%m-%d")
    print(f"Data da última extração: {date}")

    json_filename = Path(args.path_pattern.format(date=date, filename="resources.json"))
    if not json_filename.parent.exists():
        json_filename.parent.mkdir(parents=True)
    with json_filename.open(mode="w") as fobj:
        json.dump(receita.ckan_json, fobj)
    print(f"JSON salvo em {json_filename}")
    for filename, content in receita.apache_htmls:
        html_filename = Path(args.path_pattern.format(date=date, filename=filename))
        with html_filename.open(mode="w") as fobj:
            fobj.write(content)
        print(f"{filename} salvo em {html_filename}")

    downloader = subclasses[args.downloader]()
    # TODO: if recursive, will not save in correct folder
    downloader.add_many(
        [
            Download(
                url=link.url,
                filename=args.path_pattern.format(date=date, filename=link.filename),
            )
            for link in apache_links  # TODO: add option to choose between apache and ckan
        ]
    )
    downloader.run()


if __name__ == "__main__":
    main()
