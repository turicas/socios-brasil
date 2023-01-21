import datetime
import json
import re
from pathlib import Path
from urllib.parse import urljoin, unquote

import requests
from lxml.html import document_fromstring
from rows.utils.download import Download, Downloader

REGEXP_DATE = re.compile("_([0-9]{4})([0-9]{2})([0-9]{2})[_.]")


class ReceitaHTMLParser:
    url = "https://dados.gov.br/api/publico/conjuntos-dados/cadastro-nacional-da-pessoa-juridica-cnpj"

    def __init__(self, mirror=False):
        response = requests.get(self.url)
        data = response.json()
        self.json = response.json()
        self.mirror = mirror
        resource = self.json["resources"][0]
        self._extraction_date = datetime.datetime.fromisoformat(resource["created"]).date()

    @property
    def links(self):
        for resource in self.json["resources"]:
            link = resource["url"]
            if self.mirror:
                link = f"https://data.brasil.io/mirror/socios-brasil/{self._extraction_date}/" + Path(link).name
            yield link


def main():
    import argparse

    subclasses = Downloader.subclasses()
    parser = argparse.ArgumentParser()
    parser.add_argument("--path-pattern", default="data/download/{date}/{filename}")
    parser.add_argument("--downloader", choices=list(subclasses.keys()), default="aria2c")
    parser.add_argument("--mirror", action="store_true")
    args = parser.parse_args()

    receita = ReceitaHTMLParser(mirror=args.mirror)
    extraction_date = receita.extraction_date
    date = extraction_date.strftime("%Y-%m-%d")
    print(f"Data da última extração: {date}")

    json_filename = Path(args.path_pattern.format(date=date, filename="resources.json"))
    if not json_filename.parent.exists():
        json_filename.parent.mkdir(parents=True)
    with json_filename.open(mode="w") as fobj:
        json.dump(receita.json, fobj)
    print(f"JSON salvo em {json_filename}")

    downloader = subclasses[args.downloader]()
    downloader.add_many(
        [
            Download(
                url=link,
                filename=args.path_pattern.format(date=date, filename=Path(unquote(link)).name),
            )
            for link in receita.links
        ]
    )
    downloader.run()


if __name__ == "__main__":
    main()
