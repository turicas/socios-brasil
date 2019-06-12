#!/bin/bash

set -e

mkdir -p data/download data/output

CONNECTIONS=4
DOWNLOAD_URL="https://receita.economia.gov.br/orientacao/tributaria/cadastros/cadastro-nacional-de-pessoas-juridicas-cnpj/dados-publicos-cnpj"
FILE_URLS=$(wget --quiet --no-check-certificate -O - "$DOWNLOAD_URL" \
	| grep --color=no DADOS_ABERTOS_CNPJ \
	| grep --color=no ".zip" \
	| sed 's/.*"http:/http:/; s/".*//' \
	| sort)

for url in $FILE_URLS; do
	time aria2c --auto-file-renaming=false --continue=true -s $CONNECTIONS -x $CONNECTIONS --dir=data/download "$url"
done

time python extract_dump.py data/output/ data/download/DADOS_ABERTOS_CNPJ*.zip
time python extract_partner_companies.py data/output/socio.csv.gz data/output/empresa-socia.csv.gz
