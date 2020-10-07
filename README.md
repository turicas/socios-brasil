# Sócios de Empresas Brasileiras

Script que baixa todos os dados de sócios das empresas brasileiras [disponíveis
no site da Receita
Federal](https://receita.economia.gov.br/orientacao/tributaria/cadastros/cadastro-nacional-de-pessoas-juridicas-cnpj/dados-publicos-cnpj),
extrai, limpa e converte para CSV. Para entender melhor sobre quais dados estão
disponíveis, consulte a [história desse dataset](historia-do-dataset.md).


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
convertidos no Brasil.IO](https://brasil.io/dataset/socios-brasil)**.

Se esse programa e/ou os dados resultantes foram úteis a você ou à sua empresa,
considere [fazer uma doação ao projeto Brasil.IO](https://brasil.io/doe), que é
mantido voluntariamente.

Como resultado temos os seguintes arquivos:

- `empresa.csv.gz`: cadastro das empresas;
- `socio.csv.gz`: cadastro dos sócios;
- `cnae-secundaria.csv.gz`: lista de CNAEs secundárias;
- `holding.csv.gz`: cadastro das empresas que são sócias de outras
  empresas (é o arquivo `socio.csv.gz` filtrado por sócios do tipo PJ).

Além disso, os arquivos contidos nas pastas [schema](schema/) e
[schema-full](schema-full/) podem te ajudar a importar os dados para um banco
de dados (veja comandos para [SQLite](#sqlite) e [PostgreSQL](#postgresql)
abaixo).

> Nota 1: a extensão `.gz` quer dizer que o arquivo foi compactado usando gzip.
> Para descompactá-lo execute o comando `gunzip arquivo.gz` (**não é necessário
> descompactá-los** caso você siga as instruções de importação em
> [SQLite](#sqlite) e [PostgreSQL](#postgresql)).

> Nota 2: a codificação de caracteres original é ISO-8859-15, mas o script gera
> os arquivos CSV em UTF-8.

> Nota 3: se você estava usando os dados no formato anterior, veja como
> converter os novos para o padrão antigo no arquivo
> `sql/04-create-old-views.sql`.


### Privacidade

Para garantir a privacidade, evitar SPAM e publicar apenas dados corretos, o
script deleta/limpa algumas colunas com informações sensíveis ou incorretas.
Essa é a forma padrão de funcionamento para não facilitar a exposição desses
dados. Os dados censurados são:

- Na tabela `empresa`:
  - Deletadas as colunas `codigo_pais` e `nome_pais`, pois os dados contidos
    nelas estão incorretos;
  - Deletada a coluna `correio_eletronico`, para evitar SPAM;
- Na tabela `socio`:
  - Deletadas as colunas `codigo_pais` e `nome_pais`, pois os dados contidos
    nelas estão incorretos;
  - As colunas `complemento`, `ddd_fax`, `ddd_telefone_1`, `ddd_telefone_2`,
    `descricao_tipo_logradouro`, `logradouro`, `numero` terão seus dados
    deletados (ficarão em branco) para empresas que são empreendedores
    individuais (MEI, EI, EIRELI etc.) e, provavelmente, correspondem aos dados
    do sócio (endereço residencial, por exemplo);
  - Para os casos de empresas individuais que constarem o CPF na razão social
    (como é comum no caso de MEIs), o CPF será deletado.

Caso queira rodar o script sem o modo censura, altere o script `run.sh` e
adicione a opção `--no_censorship` para o script `extract_dump.py`.


### Dados auxiliares

- Cadastro Nacional de Atividades Empresariais (CNAE): existe um spider que
  baixa os metadados das [atividades empresariais (CNAEs) do site do
  IBGE](https://cnae.ibge.gov.br). Veja a função `extract_cnae` no arquivo
  `run.sh`, ela baixará os dados para as versões 1.0, 1.1, 2.0, 2.1, 2.2 e 2.3
  e salvará em `data/output`. **Nota**: esse script será melhorado/alterado,
  veja a [issue #36](https://github.com/turicas/socios-brasil/issues/36).
- Natureza jurídica: o arquivo `data/natureza-juridica.csv` contém o cadsatro
  de naturezas jurídicas das empresas (coluna `codigo_natureza_juridica` da
  tabela `empresa`).  Esse arquivo é gerado pelo script `natureza_juridica.py`,
  que baixa os [dados do site da Receita
  Federal](https://www.receita.fazenda.gov.br/pessoajuridica/cnpj/tabelas/natjurqualificaresponsavel.htm).


## Rodando

### Instalando as Dependências

Esse script depende de Python 3.7, de algumas bibliotecas e do software
[aria2](https://aria2.github.io/). Depois de instalar o Python 3.7 e o aria2,
instale as bibliotecas executando:

```bash
pip install -r requirements.txt
```

### Executando

Então basta executar o script `run.sh` para baixar os arquivos necessários e
fazer as conversões:

```bash
./run.sh
```

Você poderá rodar etapas separadamente também (leia o script [run.sh](run.sh)
para mais detalhes).

#### Agilizando o Download

[O servidor da Receita Federal onde os dados estão hospedados é **muito
lento**](https://twitter.com/turicas/status/1114185311372873729) e, por isso, o
[Brasil.IO](https://brasil.io/) disponibiliza um *mirror* de onde o download
pode ser feito mais rapidamente. Para executar o script baixando os dados do
*mirror*, execute:

```bash
./run.sh --use-mirror
```

> Nota: os *mirrors* do Brasil.IO ainda estão em fase de testes e não é
> garantido que estejam sempre atualizados.


## Importando em Bancos de Dados

Depois de executar o script ou baixar os dados já convertidos, o ideal é
importá-los em um banco de dados para facilitar consultas. Com a [interface de
linha de comando da rows](http://turicas.info/rows/cli/) é possível importá-los
rapidamente em bancos SQLite e PostgreSQL.

> Nota 1: depois de importar os dados em um banco de dados é recomendável a
> criação de índices para agilizar as consultas. Um índice bem comum é na
> coluna `cnpj` (de todas as tabelas), para facilitar encontrar uma determinada
> empresa, seus sócios e CNAEs secundários através do CNPJ. Exemplo:
> `CREATE INDEX IF NOT EXISTS idx_empresa_cnpj ON empresa (cnpj);`. Veja o
> arquivo [sql/create-indexes.sql](sql/create-indexes.sql) para uma lista de
> índices sugeridos; veja também os outros arquivos da pasta `sql/` para
> criação de tabelas auxiliares, chaves primárias e estrangeiras e o arquivo
> `import-postgresql.sh` para automatizar o processo de importação e criação
> dos índices.

> Nota 2: caso utilize a opção `--no_censorship`, utilize os arquivos da pasta
> `schema-full` em vez da pasta `schema`, pois a versão "sem censura" possui
> mais colunas.

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
rows csv2sqlite --schemas=schema/holding.csv data/output/holding.csv.gz "$DB_NAME"
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
