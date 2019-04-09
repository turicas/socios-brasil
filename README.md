# Sócios de Empresas Brasileiras

Script que baixa todos os dados de sócios das empresas brasileiras [disponíveis
no site da Receita
Federal](https://receita.economia.gov.br/orientacao/tributaria/cadastros/cadastro-nacional-de-pessoas-juridicas-cnpj/dados-publicos-cnpj),
extrai, conserta [alguns erros](#Erros) e converte para CSV. [Veja mais
detalhes](http://dados.gov.br/noticia/governo-federal-disponibiliza-os-dados-abertos-do-cadastro-nacional-da-pessoa-juridica).


## Dados

Existem dois tipos de dados:

- Os dados publicados pela RFB para qualquer um, que não possuem informações
  como CNAEs, endereços das empresas e CPFs (parciais) dos sócios;
- Os dados resultantes de um pedido de acesso à informação, que possuem as
  informações completas.

Para o primeiro caso, siga as instruções abaixo, para o segundo caso, leia
[essa seção](#dump-rfb).

**[Acesse diretamente os dados
convertidos](https://drive.google.com/open?id=1tOGB1mJZcF5V1SUS-YlPJF0-zdhfN1yd)**
caso você não queira/possa rodar o script. Na pasta `output` você encontrará os
seguintes arquivos:

- Dois arquivos por unidade federativa - lista de empresas
  (`empresas-UF.csv.xz`) e de sócios (`socios-UF.csv.xz`);
- Arquivo `socios-brasil.csv.xz`, com todos os dados de sócios consolidados;
- Arquivo `empresas-brasil.csv.xz`, com listagem de CNPJ/razão social das
  empresas de todo o país;
- Arquivo `empresas-socias.csv.xz`, com listagem das empresas sócias de outras
  empresas;
- Arquivo `socios-brasil.sqlite`, que concatena os 3 arquivos acima (cada um em
  uma tabela) em um banco de dados SQLite (facilita consultas).

> Nota: a extensão `.xz` quer dizer que o arquivo foi compactado.

Os dados originalmente estão em um formato [fixed-width
file](http://www.softinterface.com/Convert-XLS/Features/Fixed-Width-Text-File-Definition.htm)
e cada linha possui um tipo diferente de registro (empresa ou sócio), que
dificulta as análises.

O campo de qualificação do sócio foi definido com base [na tabela
disponibilizada pela Receita
Federal](http://idg.receita.fazenda.gov.br/orientacao/tributaria/cadastros/cadastro-nacional-de-pessoas-juridicas-cnpj/Qualificacao_socio.pdf)
e está disponível no arquivo
[`qualificacao-socio.csv`](qualificacao-socio.csv).

Segundo a assessoria de imprensa da Receita Federal do Brasil, a lista de CNPJs
não tem ainda registro de todas as empresas do país. A Receita disponibilizou
somente os tipos societários que possuem Quadro de Sócios e Administradores.
Ainda segundo o fisco, a lista divulgada tem somente companhias na situação
Cadastral Ativa. Empresas como as MEI e EI, por exemplo, ainda não constam na
lista.

A previsão da Receita é atualizar a lista a cada seis meses.  O órgão informou
que **não divulgará CPF dos sócios**. Somente o nome dos sócios será fornecido.
Caso seja um sócio PJ, será fornecido o número do CNPJ deste "sócio" PJ.

> Nota: a codificação de caracteres original é ISO-8859-15, mas o script gera o
> CSV em UTF-8.


### Erros

#### Razão social das sócias está incorreta

A razão social de empresas sócias (campo "nome do sócio") está incorreta: é
repetida a razão social da empresa que está sendo descrita. Exemplo: no arquivo
correspondente ao Acre, linhas 2.346 a 2.350:

```
[2346] 0100342966000107ETCA-EMPRESA DE TRANSPORTE COLETIVO DO ACRE LTDA.
[2347] 020034296600010716203660300010922ETCA-EMPRESA DE TRANSPORTE COLETIVO DO ACRE LTDA.
[2348] 02003429660001072              22BALTAZAR JOSE DE SOUSA
[2349] 02003429660001072              49RENE GOMES DE SOUSA
[2350] 02003429660001072              22LUIS GONZAGA DE SOUSA
```

A linha 2.346 descreve a empresa (CNPJ: 00342966000107, razão social:
ETCA-EMPRESA DE TRANSPORTE COLETIVO DO ACRE LTDA.) e as demais linhas descrevem
seus sócios. A linha 2.347 representa um sócio pessoa jurídica e as demais
sócios pessoa física. O sócio pessoa jurídica, cujo CNPJ é 62036603000109
aparece, no arquivo acima, como tendo razão social "ETCA-EMPRESA DE TRANSPORTE
COLETIVO DO ACRE LTDA.", que é incorreto (é o mesmo da empresa descrita).

Busca pelo CNPJ da empresa sócia em arquivos de outras unidades federativas,
encontramos uma descrição dessa empresa a partir da linha 68.178 no arquivo
correspondente ao Alagoas:

```
[68178] 0162036603000109TRANSTAZA RODOVIARIO LTDA
[68179] 02620366030001092              22RENE GOMES DE SOUSA
[68180] 02620366030001092              22BALTAZAR JOSE DE SOUSA
[68181] 02620366030001092              22RUBENS JOSE SIMOES PIMENTA
[68182] 02620366030001092              22RONAN GERALDO GOMES DE SOUSA
```

Para ter os nomes das empresas sócias corretos é necessário varrer todas as
descrições de empresas e então corrigir os nomes das empresas sócias, mas nem
sempre isso é possível (veja o próximo erro).


#### Razão social de algumas empresas é inexistente

Por conta do erro anterior não é possível saber a razão social de empresas que
não estão descritas nesses arquivos, que são os casos de pessoas exteriores.

Exemplos de CNPJs que não conseguimos identificar a razão social:
10877540000101, 17546494000107, 13779412000113. O total de CNPJs com esse
problema é de 33.708 (valor obtido rodando a consulta
`SELECT COUNT(DISTINCT(cnpj)) FROM socios WHERE nome_socio LIKE '? %'`).

> Nota: o script que converte os dados coloca um nome padronizado (começando
> com "? " nos CNPJs em que não consegue-se identificar a razão social.


#### Códigos de qualificação não descritos

Os seguintes códigos de qualificação de sócio aparecem nos arquivos, mas não na
tabela de qualificação: 18, 33, 00, 64, 09, 14, 15 e 13.

Exemplos de CNPJs que possuem sócios com qualificação não descrita:
03397208000184, 05148993000167 e 03574695000103. O total de CNPJs com esse
problema é de 2.419 (valor obtido rodando a consulta
`SELECT COUNT(DISTINCT(cnpj)) FROM socios WHERE qualificacao_socio = 'INVÁLIDA';`).


#### Cadastro incompleto de filiais

CNPJs de filiais nem sempre aparecem, exemplo: o CNPJ 36357994000145 (matriz,
razão social: INTERFOOD IMPORTACAO LTDA) aparece no arquivo de São Paulo, mas o
CNPJ 36357994000226 (filial) não aparece, mas ambos aparecem no [site de
Comprovante de Inscrição e de Situação Cadastral da Receita
Federal](https://www.receita.fazenda.gov.br/pessoajuridica/cnpj/cnpjreva/cnpjreva_solicitacao2.asp).

No total, constam 2.010 empresas na base que não são matriz, ou seja, possuem
[o sufixo](https://pt.wikipedia.org/wiki/Cadastro_Nacional_da_Pessoa_Jur%C3%ADdica#Formato)
diferente de `0001` (valor obtido pela consulta
`SELECT COUNT(*) AS quantidade FROM empresas WHERE SUBSTR(cnpj, 9, 4) != '0001';`).


#### Empresas com razão social em branco

Duas empresas possuem razão social em branco, ambas de São Paulo. Os CNPJs são
os seguintes: 08013165000533 e 08393057000533.

Valores obtidos rodando a consulta:
`SELECT cnpj, uf FROM socios WHERE razao_social = '';`


#### Sócios não possuem identificador único

Um total de 3.045.729 nomes de sócios que aparecem em mais uma empresa (valor
obtido com a consulta
`SELECT COUNT(*) FROM (SELECT nome_socio, COUNT(*) AS quantidade FROM socios GROUP by nome_socio HAVING COUNT(*) > 1 ORDER BY quantidade DESC);`),
desses, o nome que mais aparece é "JOSE CARLOS DA SILVA", com 2.083 aparições
(valor obtido com a consulta
`SELECT nome_socio, COUNT(*) AS quantidade FROM socios GROUP by nome_socio HAVING COUNT(*) > 1 ORDER BY quantidade DESC LIMIT 1;`).
"José" é o nome masculino mais comum do Brasil [segundo o
IBGE](https://censo2010.ibge.gov.br/nomes/) (perde apenas para "Maria") e
provavelmente existem diversas pessoas chamadas "JOSE CARLOS DA SILVA" que são
sócios de empresas.

Como o dataset liberado pela Receita Federal não possui CPF dos sócios, fica
**impossível** determinar os homônimos, que é um **problema gravíssimo**.

Caso o objetivo ao não divulgar o CPF seja proteger o sigilo dos sócios, é
possível gerar um identificador único (como
[UUID](https://en.wikipedia.org/wiki/Universally_unique_identifier)) baseado no
CPF original, dessa forma, o CPF original não será disponibilizado mas mesmo
assim os usuários do dataset poderão desambiguar os homônimos. Uma outra
solução possível (melhor) seria disponibilizar apenas alguns números do CPF -
essa alternativa continua protegendo o número de CPF completo e pode ser útil
para casos em que possui-se o CPF completo para fazer o cruzamento (sugestão:
liberar os dígitos que aparecem como "9" nessa máscara: xxx.999.99x-xx -
omitindo o nono dígito será impossível determinar em que região a pessoa
registrou o CPF e omitindo os dígitos verificadores será impossível fazer
ataques de engenharia reversa para descobrir outros dígitos).


#### Base incompleta

- Alguns CNPJs não constam nos arquivos (como EI, MEI e de candidatos e
  empresas inativas), tornando a base incompleta e de difícil cruzamento com
  outras bases, principalmente quanto a dados históricos (não possui cadastro
  de empresas inativas, por exemplo).
- Essa base de dados não possui mais informações das empresas, como lista de
  CNAEs e endereço (que estão disponíveis apenas através de consultas
  no site da Receita Federal, onde é necessário preencher um CAPTCHA).


#### Formato não padronizado

- Os dados estão em um formato não padronizado ([fixed-width
  file](http://www.softinterface.com/Convert-XLS/Features/Fixed-Width-Text-File-Definition.htm)),
  onde os metadados (como o nome de cada coluna) são totalmente personalizados
  para esse caso e precisam ser descobertos através de [uma imagem disponível
  no site da Receita
  Federal](http://idg.receita.fazenda.gov.br/orientacao/tributaria/cadastros/cadastro-nacional-de-pessoas-juridicas-cnpj/Leiaute.jpg).
  Caso os dados estivessem disponíveis em um formato padronizado e aberto, como
  o CSV, os nomes das colunas poderiam ser descritos na primeira linha do
  arquivo, não necessitando a criação de um software específico para leitura
  dos mesmos;
- Registros de tipos diferentes (empresa e sócio) estão juntos nos mesmos
  arquivos, dificultando ainda mais a extração - poderiam estar em arquivos
  distintos (um que possui CNPJ, razão social e endereço das empresas e outro
  que descreve os sócios de cada empresa);
- Os arquivos poderiam estar compactados (o que reduziria drasticamente o tempo
  de transferência), dado que alguns possuem gigabytes de tamanho.


## Rodando

Esse script depende de Python 3.6 e de algumas bibliotecas. Instale-as
executando:

```bash
pip install -r requirements.txt
```

Você deverá rodá-lo em várias etapas:


### Criar o script que baixa os arquivos

```bash
python3 socios.py create-download-script
```

Após executar, um arquivo `download.sh` será criado. Esse script precisa do
`wget` instalado (que é o padrão em distribuições GNU/Linux - caso use MacOS,
instale-o rodando `brew install wget`).


### Baixar os dados da Receita Federal:

```bash
sh download.sh
```

Esse download poderá demorar bastante.
Serão baixados diversos arquivos `.txt` no diretório `download`. Essa etapa
poderá demorar bastante. Veja na [seção Downloads](#Downloads) o tamanho de
cada arquivo.


### Extrair, consertar e converter em CSV:

```bash
python3 socios.py convert-all
```

Um diretório `output` será criado com os CSVs (que estarão com codificação
UTF-8, separados por vírgula).

Caso queira converter apenas um arquivo, você poderá utilizar o subcomando
`convert-file`, passando o nome do arquivo de origem e os nomes de destino,
exemplo:

```bash
python3 socios.py convert-file \
	--input-filename=download/Paraná.txt \
	--output_companies_filename=output/empresas-PR.csv.xz \
	--output_partners_filename=output/socios-PR.csv.xz
```


### Gerar arquivo para todo o Brasil:

Para gerar o arquivo consolidando os sócios de todas as unidades federativas
(`output/pre-socios-brasil.csv.xz`), execute:

```bash
python3 socios.py merge-partner-files
```

### Consertando os nomes de empresas sócias:

Os nomes de empresas sócias vem com erros (esses erros estão nos dados da
Receita Federal - veja a [seção Erros](#Erros)) e você pode rodar um comando
que lê o arquivo e corrige os nomes que forem possíveis:

```bash
python3 socios.py fix-partner-file
```

O comando acima irá gerar o arquivo `output/socios-brasil.csv.xz`.


### Extraindo empresas

Para extrair as empresas (CNPJ e razão social) de todo o Brasil, rode:

```bash
python3 socios.py extract-companies
```

O arquivo `output/empresas-brasil.csv.xz` será criado.


### Extraindo empresas sócias

Para extrair as relações entre empresas, rode:

```bash
python3 socios.py extract-company-company-partnerships
```

O arquivo `output/empresas-socias.csv.xz` será criado.

### Convertendo para SQLite

Para gerar a base de dados SQLite (facilita consultas), rode o seguinte
comando:

```bash
python3 csv2sqlite.py
```

Esse arquivo converte o arquivo `output/socios-brasil.csv.xz` em
`output/socios-brasil.sqlite`.


### Rodando tudo

Para facilitar, você poderá rodar o script `run.sh`, que executa todos os
comandos.


### Downloads

Previsão de tamanhos dos arquivos a serem baixados (atualizado em 2018-06-03):

- Acre: 7,7MB
- Alagoas: 31MB
- Amapá: 8,1MB
- Amazonas: 34MB
- Bahia: 221MB
- Ceará: 100MB
- Distrito Federal: 103MB
- Espírito Santo: 98MB
- Goiás: 173MB
- Maranhão: 60MB
- Mato Grosso: 74MB
- Mato Grosso do Sul: 54MB
- Minas Gerais: 525MB
- Pará: 79MB
- Paraíba: 40MB
- Paraná: 383MB
- Pernambuco: 119MB
- Piauí: 31MB
- Rio de Janeiro: 465MB
- Rio Grande do Norte: 43MB
- Rio Grande do Sul: 368MB
- Rondônia: 32MB
- Roraima: 6,2MB
- Santa Catarina: 269MB
- São Paulo: 1,5GB
- Sergipe: 33MB
- Tocantins: 26MB

Total: 4,8 GB.


### Em Outras Linguagens

Se você usa R, veja o
[RFBCNPJ](http://curso-r.com/blog/2018/05/13/2018-05-13-rfbcnpj/).


## Dump RFB

Instale as dependências:

```bash
pip install -r requirements.txt
```

Baixe o arquivo zip fornecido pela RFB.

Crie um diretório para os arquivos-saída e execute o script:

```bash
mkdir -p data/output/
python extract_dump.py ~/Downloads/F.K032001K.D81106A.zip data/output/
```
