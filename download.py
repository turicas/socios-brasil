import datetime
import re
from pathlib import Path
from urllib.parse import urljoin

import requests
from lxml.html import document_fromstring
from rows.utils.download import Downloader, DownloadLink

REGEXP_DATE = re.compile("_([0-9]{4})([0-9]{2})([0-9]{2})[_.]")


def download_history(year, path_pattern="data/download/{date}/{filename}", downloader="aria2c-file"):
    url = f"http://200.152.38.155/CNPJ_historico/{year}/"
    response = requests.get(url)
    tree = document_fromstring(response.text)
    subclasses = Downloader.subclasses()
    downloader = subclasses[downloader]()
    for filename in tree.xpath("//a/@href"):
        result = REGEXP_DATE.findall(filename)
        if not result:
            continue
        year, month, day = result[0]
        date = f"{year}-{month}-{day}"
        downloader.add(
            DownloadLink(
                url=urljoin(url, filename),
                save_path=Path(path_pattern.format(date=date, filename=filename)).absolute(),
            )
        )
    downloader.run()


class ReceitaHTMLParser:
    url = (
        "https://www.gov.br/receitafederal/pt-br/assuntos/orientacao-tributaria/cadastros/consultas/dados-publicos-cnpj"
    )

    def __init__(self, mirror=False):
        response = requests.get(self.url)
        self.html = response.text
        self.tree = document_fromstring(self.html)
        self.mirror = mirror
        self._extraction_date = None

    @property
    def links(self):
        yielded = set()
        for link in self.tree.xpath("//a[contains(@href, '.zip')]/@href"):
            link = link.replace("http://http//", "http://")
            if self.mirror:
                link = f"https://data.brasil.io/mirror/socios-brasil/{self.extraction_date}/" + Path(link).name
            if link not in yielded:
                yield link
                yielded.add(link)

    @property
    def extraction_date(self):
        if self._extraction_date is None:
            last_extraction = self.tree.xpath("//*[contains(text(), 'Data da última extração:')]//text()")[0]
            result = re.findall("([0-9]{1,2})/([0-9]{1,2})/([0-9]{2,4})", last_extraction)
            date_parts = [int(part) for part in reversed(result[0])]
            self._extraction_date = datetime.date(*date_parts)
        return self._extraction_date


def main():
    import argparse

    subclasses = Downloader.subclasses()
    parser = argparse.ArgumentParser()
    parser.add_argument("--path-pattern", default="data/download/{date}/{filename}")
    parser.add_argument("--downloader", choices=list(subclasses.keys()), default="aria2c-file")
    parser.add_argument("--mirror", action="store_true")
    parser.add_argument("versao", choices=("historico-2021", "historico-2022", "atual"))
    args = parser.parse_args()

    if args.versao == "atual":
        receita = ReceitaHTMLParser(mirror=args.mirror)
        extraction_date = receita.extraction_date
        print(f"Data da última extração: {extraction_date}")

        date = extraction_date.strftime("%Y-%m-%d")
        index_filename = Path(args.path_pattern.format(date=date, filename="index.html"))
        if not index_filename.parent.exists():
            index_filename.parent.mkdir(parents=True)
        with index_filename.open(mode="w") as fobj:
            fobj.write(receita.html)
        print(f"HTML salvo em {index_filename}")

        downloader = subclasses[args.downloader]()
        downloader.add_many(
            [
                DownloadLink(
                    url=link,
                    save_path=args.path_pattern.format(date=date, filename=Path(link).name),
                )
                for link in receita.links
            ]
        )
        downloader.run()

    elif args.versao.startswith("historico-"):
        year = args.versao.replace("historico-", "")
        download_history(
            year,
            path_pattern=args.path_pattern,
            downloader=args.downloader,
        )


if __name__ == "__main__":
    main()
