from urllib.parse import urljoin

import scrapy
from lxml.html import document_fromstring


def get_text(lines):
    """Return text from "text()" XPath result as a string, removing whitespaces

    >>> get_text(["\\t", "   teste   ", "\\n", "123 "])
    'teste 123'
    """

    return " ".join([line.strip() for line in lines if line.strip()])


class CNAESpider(scrapy.Spider):
    name = "cnae"
    versoes = {
        "1.0": "https://cnae.ibge.gov.br/?option=com_cnae&view=estrutura&Itemid=6160&tipo=cnae&versao_classe=1.0.1&versao_subclasse=2.1.1",
        "1.1": "https://cnae.ibge.gov.br/?option=com_cnae&view=estrutura&Itemid=6160&tipo=cnae&versao_classe=3.0.1&versao_subclasse=4.1.1",
        "2.0": "https://cnae.ibge.gov.br/?option=com_cnae&view=estrutura&Itemid=6160&tipo=cnae&versao_classe=5.0.1&versao_subclasse=6.1.1",
        "2.1": "https://cnae.ibge.gov.br/?option=com_cnae&view=estrutura&Itemid=6160&tipo=cnae&versao_classe=7.0.0&versao_subclasse=8.1.1",
        "2.2": "https://cnae.ibge.gov.br/?option=com_cnae&view=estrutura&Itemid=6160&tipo=cnae&versao_classe=7.0.0&versao_subclasse=9.1.1",
        "2.3": "https://cnae.ibge.gov.br/?option=com_cnae&view=estrutura&Itemid=6160&tipo=cnae&versao_classe=7.0.0&versao_subclasse=10.1.0",
    }
    parsers = {
        "root": {
            "xpath_items": "//table[@id = 'tbEstrutura']/tbody/tr",
            "xpath_id": ".//td[1]/a/text()",
            "xpath_description": ".//td[3]/text()",
            "xpath_url": ".//td[1]/a/@href",
            "next": "secao",
        },
        "secao": {
            "id_length": 1,
            "xpath_items": "//table[@class = 'tabela-hierarquia']//td[a[contains(@href, 'divisao=')]]",
            "xpath_id": ".//a/text()",
            "xpath_description": ".//text()",
            "xpath_url": ".//a/@href",
            "next": "divisao",
        },
        "divisao": {
            "id_length": 2,
            "xpath_items": "//table[@class = 'tabela-hierarquia']//td[a[contains(@href, 'grupo=')]]",
            "xpath_id": ".//a/text()",
            "xpath_description": ".//text()",
            "xpath_url": ".//a/@href",
            "next": "grupo",
        },
        "grupo": {
            "id_length": 4,
            "xpath_items": "//table[@class = 'tabela-hierarquia']//td[a[contains(@href, 'classe=')]]",
            "xpath_id": ".//a/text()",
            "xpath_description": ".//text()",
            "xpath_url": ".//a/@href",
            "next": "classe",
        },
        "classe": {
            "id_length": 7,
            "xpath_items": "//table[@class = 'tabela-hierarquia']//td[a[contains(@href, 'subclasse=')]]",
            "xpath_id": ".//a/text()",
            "xpath_description": ".//text()",
            "xpath_url": ".//a/@href",
            "next": "subclasse",
        },
    }

    def __init__(self, versao=None, *args, **kwargs):
        super().__init__(*args, **kwargs)
        if not versao:
            raise ValueError("O parâmetro 'versao' é obrigatório")
        self.versao = versao

    def start_requests(self):
        return [scrapy.Request(url=self.versoes[self.versao], callback=self.parse)]

    def parse(self, response):
        yield {
            "id_subclasse": "8888-8/88",
            "descricao_subclasse": "Não identificada",
            "id_classe": "88.88-8",
            "descricao_classe": "Não identificada",
            "id_grupo": "88.8",
            "descricao_grupo": "Não identificado",
            "id_divisao": "88",
            "descricao_divisao": "Não identificada",
            "id_secao": "8",
            "descricao_secao": "Não identificada",
            "notas_explicativas": "",
            "url": "",
            "id": 8888888,
            "versao": self.versao,
        }
        yield from self.parse_items(response, root_name="root")

    def parse_items(self, response, root_name=None):
        """Recursively get data/make requests for all parser hierarchical levels"""

        data = response.request.meta.get("data", {})
        root_name = root_name or response.request.meta["root_name"]
        metadata = self.parsers[root_name]
        xpath_id = metadata["xpath_id"]
        xpath_description = metadata["xpath_description"]
        xpath_url = metadata["xpath_url"]
        item_name = metadata["next"]
        for item in response.xpath(metadata["xpath_items"]):
            tree = document_fromstring(item.extract())
            url = urljoin("https://cnae.ibge.gov.br/", tree.xpath(xpath_url)[0])
            item_id = get_text(tree.xpath(xpath_id))
            item_description = get_text(tree.xpath(xpath_description))
            item_data = {}
            if item_name == "subclasse" or len(item_id) == self.parsers[item_name]["id_length"]:
                next_root_name = item_name
            else:
                descricao = response.xpath("//span[@class = 'destaque']//text()").extract()[0]
                item_data[f"id_{item_name}"] = descricao.split()[0]
                item_data[f"descricao_{item_name}"] = descricao
                next_root_name = self.parsers[item_name]["next"]
            item_data.update({
                f"id_{next_root_name}": item_id.strip(),
                f"descricao_{next_root_name}": item_description.strip(),
            })
            item_data.update(data)

            callback = self.parse_items if next_root_name != "subclasse" else self.parse_subclasse
            yield scrapy.Request(
                url=url,
                meta={"data": item_data, "root_name": next_root_name},
                callback=callback,
            )

    def parse_subclasse(self, response):
        """Yield the subclass item (last mile of the recursive strategy)"""
        data = response.request.meta["data"]
        tree = document_fromstring(response.body)
        data["notas_explicativas"] = "\n".join(
            [
                line.strip()
                for line in tree.xpath('//div[@id = "notas-explicativas"]//text()')
                if line.strip()
            ]
        )
        data["url"] = response.request.url
        data["id"] = int(data["id_subclasse"].replace("/", "").replace("-", ""))
        data["versao"] = self.versao
        yield data
