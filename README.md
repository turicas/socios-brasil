# Sócios de Empresas Brasileiras

Script que baixa todos os dados de sócios das empresas brasileiras [disponíveis
no site da Receita
Federal](http://idg.receita.fazenda.gov.br/orientacao/tributaria/cadastros/cadastro-nacional-de-pessoas-juridicas-cnpj/dados-abertos-do-cnpj),
extrai e converte para CSV. [Veja mais detalhes](http://dados.gov.br/noticia/governo-federal-disponibiliza-os-dados-abertos-do-cadastro-nacional-da-pessoa-juridica).


## Dados

**[Acesse diretamente os dados
convertidos](https://drive.google.com/open?id=1o2q2FxK9RecbwrhYxlXj25qWJHh2guhi)**
caso você não queira/possa rodar o script (esses dados foram baixados e
convertidos em 31 de janeiro de 2018). Na pasta "output" você encontrará,
compactados:

- Um arquivo por unidade federativa;
- Arquivo `Brasil.csv`, com todos os dados consolidados;
- Arquivo `socios-brasil.sqlite` - arquivo acima convertido para SQLite, para
  facilitar consultas.

Cada registro dos arquivos acima representa um sócio.

Os dados originalmente estão em um formato [fixed-width
file](http://www.softinterface.com/Convert-XLS/Features/Fixed-Width-Text-File-Definition.htm)
e cada linha possui um tipo diferente de registro (empresa ou sócio), que
dificulta as análises.

O campo de qualificação do sócio foi definido com base [na tabela
disponibilizada pela Receita
Federal](http://idg.receita.fazenda.gov.br/orientacao/tributaria/cadastros/cadastro-nacional-de-pessoas-juridicas-cnpj/Qualificacao_socio.pdf)
e está disponível no arquivo
[`qualificacao-socios.csv`](qualificacao-socios.csv).

> Nota: a codificação de caracteres original é ISO-8859-15, mas o script gera o
> CSV em UTF-8.


### Erros

- Algumas empresas não constam nos arquivos acima, acredito que sejam dados não
  muito atuais.


## Rodando

Esse script depende de Python 3.6 e de algumas bibliotecas. Instale-as
executando:

```bash
pip install -r requirements.txt
```

Você deverá rodá-lo em várias etapas:

- Criar o script que baixa os arquivos fix-width
- Baixar os arquivos
- Converter os arquivos para cada unidade federativa (gerando CSVs)
- Juntar os CSVs em um só (para todo o Brasil)

Criando o script que baixa os arquivos:

```bash
python3 socios.py create-download-script
```

Após executar, um arquivo `download.sh` será criado. Rode-o (necessita de wget
instalado - testado apenas em Debian GNU/Linux):

```bash
sh download.sh
```

Poderá demorar. Vários arquivos `.txt` serão baixados para o diretório
`download`.  Converta-os para CSV com o seguinte comando:

```bash
python3 socios.py convert-all
```

Um diretório `output` será criado com os CSVs (que estarão com codificação
UTF-8, separados por vírgula).

Caso queira converter apenas um arquivo, você poderá utilizar o subcomando
`convert-file`, passando o nome do arquivo de origem e o nome de destino,
exemplo:

```bash
python3 socios.py convert-file --input-filename=download/Paraná.txt --output-filename=output/Paraná.csv
```

Para gerar o `output/Brasil.csv`, execute:

```bash
python3 socios.py merge-all
```

Para gerar a base de dados SQLite (facilita consultas), rode o seguinte
comando:

```bash
python3 csv2sqlite.py
```
 ### Downloads
 
 Previsão de tamanhos dos arquivos a serem puxados (atualizado em **2018-2-1**):
 
* Acre: 8013978 (7,6M) 
* Alagoas: 32437339 (31M)
* Amapá:  8404764 (8,0M)
* Amazonas:  35411591 (34M)
* Bahia: 231116303 (220M) 
* Ceará: 104380545 (100M)
* Distrito Federal:  107598131 (103M) 
* Espírito Santo: 101900028 (97M)
* Goiás : 181131794 (173M)
* Maranhão: 62187690 (59M)
* Mato Grosso: 77130002 (74M)
* Mato Grosso do Sul: 55749271 (53M) 
* Minas Gerais: 549952985 (524M)
* Pará:  82718853 (79M)
* Paraíba: 41613361 (40M)
* Paraná: 401246497 (383M)
* Pernambuco: 124284464 (119M)
* Piauí: 31827285 (30M) 
* Rio de Janeiro: 487426461 (465M)
* Rio Grande do Norte: 44115843 (42M)
* Rio Grande do Sul: 385868132 (368M)
* Rondônia: 32882369 (31M)
* Roraima: 6426195 (6,1M)
* Santa Catarina: 281316642 (268M)
* São Paulo: 1588432400 (1,5G)
* Sergipe:  33880344 (32M)
* Tocantins:  27034140 (26M)
