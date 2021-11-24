import requests
from lxml.html import document_fromstring

url = "https://www.gov.br/receitafederal/pt-br/assuntos/orientacao-tributaria/cadastros/consultas/dados-publicos-cnpj"

response = requests.get(url)
tree = document_fromstring(response.text)
for link in tree.xpath("//a[contains(@href, '.zip')]/@href"):
    print(link)
