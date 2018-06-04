# Sócios de Empresas Brasileiras

Script que baixa todos os dados de sócios das empresas brasileiras [disponíveis
no site da Receita
Federal](http://idg.receita.fazenda.gov.br/orientacao/tributaria/cadastros/cadastro-nacional-de-pessoas-juridicas-cnpj/dados-abertos-do-cnpj),
extrai, conserta alguns erros e converte para CSV. [Veja mais
detalhes](http://dados.gov.br/noticia/governo-federal-disponibiliza-os-dados-abertos-do-cadastro-nacional-da-pessoa-juridica).


## Dados

**[Acesse diretamente os dados
convertidos](https://drive.google.com/open?id=1o2q2FxK9RecbwrhYxlXj25qWJHh2guhi)**
caso você não queira/possa rodar o script. Na pasta "output" você encontrará,
compactados:

- Um arquivo por unidade federativa;
- Arquivo `Brasil.csv`, com todos os dados consolidados;
- Arquivo `socios-brasil.sqlite` - arquivo acima convertido para SQLite, para
  facilitar consultas.

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

- Algumas empresas não constam nos arquivos acima, acredito que sejam dados não
  muito atuais.


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
