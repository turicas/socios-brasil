#!/bin/bash

set -e

mkdir -p data/download data/output

DOWNLOAD_URL="https://receita.economia.gov.br/orientacao/tributaria/cadastros/cadastro-nacional-de-pessoas-juridicas-cnpj/dados-publicos-cnpj"
FILE_URLS=$(wget --quiet --no-check-certificate -O - "$DOWNLOAD_URL" \
	| grep --color=no DADOS_ABERTOS_CNPJ \
	| grep --color=no ".zip" \
	| sed 's/.*"http:/http:/; s/".*//' \
	| sort)

echo "$FILE_URLS" > download.txt
for url in $FILE_URLS; do
	time aria2c -s 4 -x 4 --dir=data/download/ "$url"
	time zip -F data/download/DADOS_ABERTOS_CNPJ.zip --out data/download/DADOS_ABERTOS_CNPJ-fixed.zip
	rm data/download/DADOS_ABERTOS_CNPJ.zip
done

time python extract_dump.py data/download/DADOS_ABERTOS_CNPJ-fixed.zip data/output/
time python extract_partner_companies.py data/output/socio.csv.gz data/output/empresa-socia.csv.gz
