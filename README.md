# Sócios de Empresas Brasileiras

Script que baixa todos os dados de sócios das empresas brasileiras [disponíveis
no site da Receita
Federal](https://receita.economia.gov.br/orientacao/tributaria/cadastros/cadastro-nacional-de-pessoas-juridicas-cnpj/dados-publicos-cnpj),
extrai, conserta [alguns erros](#Erros) e converte para CSV. [Veja mais
detalhes](http://dados.gov.br/noticia/governo-federal-disponibiliza-os-dados-abertos-do-cadastro-nacional-da-pessoa-juridica).


## Licença

A licença do código é [LGPL3](https://www.gnu.org/licenses/lgpl-3.0.en.html). e
dos dados [Creative Commons Attribution
ShareAlike](https://creativecommons.org/licenses/by-sa/4.0/). Caso utilize os
dados, cite a fonte original e quem tratou os dados, como: **Fonte: Receita
Federal do Brasil, dados tratados por Álvaro
Justen/[Brasil.IO](https://brasil.io/)**. Caso compartilhe os dados, **utilize
a mesma licença**.


## Dados

### Entrada

Os dados publicados para Receita Federal do Brasil contemplam as seguintes
tabelas:

- Cadastro das empresas, incluindo CNPJ, razão social, nome fantasia, endereço,
  CNAE fiscal e outros;
- Cadastro de sócios, contendo CNPJ da empresa, documento do sócio, nome do
  sócio e outros;
- CNAEs secundários para cada CNPJ.

Os dados originalmente estão em um formato [fixed-width
file](http://www.softinterface.com/Convert-XLS/Features/Fixed-Width-Text-File-Definition.htm)
e cada linha possui um tipo diferente de registro (empresa, sócio, CNAE
secundária, header ou trailler), que dificulta as análises.

O campo de qualificação do sócio foi definido com base [na tabela
disponibilizada pela Receita
Federal](http://idg.receita.fazenda.gov.br/orientacao/tributaria/cadastros/cadastro-nacional-de-pessoas-juridicas-cnpj/Qualificacao_socio.pdf)
e está disponível no arquivo
[`qualificacao-socio.csv`](qualificacao-socio.csv).


### Saída

Além de extrair os dados do arquivo origingal, o script gera uma nova tabela
contendo as empresas que são sócias de outras empresas (para facilitar buscas
de *holdings*).

Caso você não queira/possa rodar o script, **[acesse diretamente os dados
convertidos](https://drive.google.com/open?id=1tOGB1mJZcF5V1SUS-YlPJF0-zdhfN1yd)**.
Cada pasta corresponde à data de coleta do arquivo, onde dentro você deverá
acessar a pasta `output`, que encontrará os seguintes arquivos:

- `empresa.csv.gz`: cadastro das empresas;
- `socio.csv.gz`: cadastro dos sócios;
- `cnae-secundaria.csv.gz`: lista de CNAEs secundárias;
- `empresa-socia.csv.gz`: cadastro das empresas que são sócias de outras
  empresas (é o arquivo `socio.csv.gz` filtrado por sócios do tipo PJ).

Além disso, os arquivos contidos na pasta [schema](schema/) podem ajudá-lo a
importar os dados para um banco de dados.

> Nota 1: a extensão `.gz` quer dizer que o arquivo foi compactado usando gzip.
> Para descompactá-lo execute o comando `gunzip arquivo.gz`.

> Nota 2: a codificação de caracteres original é ISO-8859-15, mas o script gera o
> CSV em UTF-8.


## Rodando

Esse script depende de Python 3.7 e de algumas bibliotecas. Instale-as
executando:

```bash
pip install -r requirements.txt
```

Então basta executar o script `run.sh` para baixar os arquivos necessários e
fazer as conversões:

```bash
./run.sh
```

Você poderá rodar os scripts em etapas também -- leia o `run.sh` para mais
detalhes.


## Em Outras Linguagens

Se você usa R, veja os seguintes pacotes:
- [qsacnpj](https://github.com/georgevbsantiago/qsacnpj/)
- [RFBCNPJ](http://curso-r.com/blog/2018/05/13/2018-05-13-rfbcnpj/)
