# Sócios de Empresas Brasileiras

Script que baixa todos os dados de sócios das empresas brasileiras [disponíveis
no site da Receita
Federal](https://receita.economia.gov.br/orientacao/tributaria/cadastros/cadastro-nacional-de-pessoas-juridicas-cnpj/dados-publicos-cnpj),
extrai, limpa e converte para CSV. [Veja mais
detalhes](http://dados.gov.br/noticia/governo-federal-disponibiliza-os-dados-abertos-do-cadastro-nacional-da-pessoa-juridica).


## Licença

A licença do código é [LGPL3](https://www.gnu.org/licenses/lgpl-3.0.en.html) e
dos dados convertidos [Creative Commons Attribution
ShareAlike](https://creativecommons.org/licenses/by-sa/4.0/). Caso utilize os
dados, **cite a fonte original e quem tratou os dados**, como: **Fonte: Receita
Federal do Brasil, dados tratados por Álvaro
Justen/[Brasil.IO](https://brasil.io/)**. Caso compartilhe os dados, **utilize
a mesma licença**.


## Dados

### Entrada

Os dados publicados pela Receita Federal do Brasil contemplam as seguintes
tabelas:

- Cadastro das empresas, incluindo CNPJ, razão social, nome fantasia, endereço,
  CNAE fiscal e outros;
- Cadastro de sócios, contendo CNPJ da empresa, documento do sócio, nome do
  sócio e outros;
- CNAEs secundários para cada CNPJ.

Os dados originalmente estão em um formato [fixed-width
file](http://www.softinterface.com/Convert-XLS/Features/Fixed-Width-Text-File-Definition.htm)
e cada linha possui um tipo diferente de registro (empresa, sócio, CNAE
secundária, header ou trailler), que dificulta qualquer tipo de análise, sendo
necessária a conversão para formatos mais amigáveis.

O campo de qualificação do sócio foi definido com base [na tabela
disponibilizada pela Receita
Federal](http://idg.receita.fazenda.gov.br/orientacao/tributaria/cadastros/cadastro-nacional-de-pessoas-juridicas-cnpj/Qualificacao_socio.pdf)
e está disponível no arquivo
[`qualificacao-socio.csv`](qualificacao-socio.csv). Em breve também teremos
arquivos com os nomes dos CNAEs e situação cadastral ([veja mais detalhes
aqui](https://github.com/turicas/socios-brasil/issues/20)).


### Saída

Além de extrair os dados do arquivo origingal, o script gera uma nova tabela
contendo as empresas que são sócias de outras empresas (para facilitar buscas
de *holdings*).

Caso você não queira/possa rodar o script, **[acesse diretamente os dados
convertidos](https://drive.google.com/open?id=1tOGB1mJZcF5V1SUS-YlPJF0-zdhfN1yd)**.
Cada pasta corresponde à data de coleta do arquivo, onde dentro você deverá
acessar a pasta `output`, que contém os seguintes arquivos:

- `empresa.csv.gz`: cadastro das empresas;
- `socio.csv.gz`: cadastro dos sócios;
- `cnae-secundaria.csv.gz`: lista de CNAEs secundárias;
- `empresa-socia.csv.gz`: cadastro das empresas que são sócias de outras
  empresas (é o arquivo `socio.csv.gz` filtrado por sócios do tipo PJ).

Além disso, os arquivos contidos na pasta [schema](schema/) podem te ajudár a
importar os dados para um banco de dados (veja comandos para [SQLite](#sqlite)
e [PostgreSQL](#postgresql) abaixo).

> Nota 1: a extensão `.gz` quer dizer que o arquivo foi compactado usando gzip.
> Para descompactá-lo execute o comando `gunzip arquivo.gz` (**não é necessário
> descompactá-los** caso você siga as instruções de importação em
> [SQLite](#sqlite) e [PostgreSQL](#postgresql)).

> Nota 2: a codificação de caracteres original é ISO-8859-15, mas o script gera
> os arquivos CSV em UTF-8.

### Privacidade

Para garantir a privacidade de algumas pessoas e evitar SPAM, o script
deleta/limpa algumas colunas com informações sensíveis. Essa será a forma
padrão de funcionamento para não facilitar a exposição desses dados (em breve
[será adicionada uma opção para extrair completametne os
dados](https://github.com/turicas/socios-brasil/issues/23)).


## Rodando

Esse script depende de Python 3.7, de algumas bibliotecas e do software
[aria2](https://aria2.github.io/). Depois de instalar o Python 3.7 e o aria2,
instale as bibliotecas executando:

```bash
pip install -r requirements.txt
```

Então basta executar o script `run.sh` para baixar os arquivos necessários e
fazer as conversões:

```bash
./run.sh
```

Você poderá rodar etapas separadamente também (leia o script [run.sh](run.sh)
para mais detalhes).


## Importando em Bancos de Dados

Depois de executar o script ou baixar os dados já convertidos, o ideal é
importá-los em um banco de dados para facilitar consultas. Com a [interface de
linha de comando da rows](http://turicas.info/rows/cli/) é possível importá-los
rapidamente em bancos SQLite e PostgreSQL.

> Nota: depois de importar os dados em um banco de dados é recomendável a
> criação de índices para agilizar as consultas. Um índice bem comum é na
> coluna `cnpj` (de todas as tabelas), para facilitar encontrar uma determinada
> empresa, seus sócios e CNAEs secundários através do CNPJ. Exemplo:
> `CREATE INDEX IF NOT EXISTS idx_empresa_cnpj ON empresa (cnpj);`.

### SQLite

Instale a CLI da rows e a versão de desenvolvimento da biblioteca rodando
(requer Python 3.7+):

```bash
pip install rows[cli]
pip install -U https://github.com/turicas/rows/archive/develop.zip
```

Agora, com os arquivos na pasta `data/output` basta executar os seguintes
comandos:

```bash
DB_NAME="data/output/socios-brasil.sqlite"
rows csv2sqlite --schemas=schema/empresa.csv data/output/empresa.csv.gz "$DB_NAME"
rows csv2sqlite --schemas=schema/socio.csv data/output/empresa-socia.csv.gz "$DB_NAME"
rows csv2sqlite --schemas=schema/socio.csv data/output/socio.csv.gz "$DB_NAME"
rows csv2sqlite --schemas=schema/cnae-secundaria.csv data/output/cnae-secundaria.csv.gz "$DB_NAME"
```

Pegue um café, aguarde alguns minutos e depois desfrute do banco de dados em
`data/output/socios-brasil.sqlite`. :)


### PostgreSQL

Instale a CLI da rows, as dependências do PostgreSQL e a versão de
desenvolvimento da biblioteca rodando (requer Python 3.7+):

```bash
pip install rows[cli]
pip install rows[postgresql]
pip install -U https://github.com/turicas/rows/archive/develop.zip
```

Agora, com os arquivos na pasta `data/output` basta executar os seguintes
comandos (não esqueça de preencher a variável `POSTGRESQL_URI` corretamente):

```bash
POSTGRESQL_URI="postgres://<user>:<pass>@<host>:<port>/<dbname>"  # PREENCHA!
rows pgimport --schema=schema/empresa.csv data/output/empresa.csv.gz $POSTGRESQL_URI empresa
rows pgimport --schema=schema/socio.csv data/output/empresa-socia.csv.gz $POSTGRESQL_URI empresa_socia
rows pgimport --schema=schema/socio.csv data/output/socio.csv.gz $POSTGRESQL_URI socio
rows pgimport --schema=schema/cnae-secundaria.csv data/output/cnae-secundaria.csv.gz $POSTGRESQL_URI cnae_secundaria
```

Pegue um café, aguarde alguns minutos e depois desfrute do banco de dados em
`$POSTGRESQL_URI`. :)


## Outras Implementações

Em R:

- [qsacnpj](https://github.com/georgevbsantiago/qsacnpj/)
- [RFBCNPJ](http://curso-r.com/blog/2018/05/13/2018-05-13-rfbcnpj/)

Em Python:

- [CNPJ-full](https://github.com/fabioserpa/CNPJ-full)
