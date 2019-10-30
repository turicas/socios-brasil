#!/bin/bash

set -e

mkdir -p data/download data/output

if [ "$1" = "--use-mirror" ]; then
	USE_MIRROR=true
else
	USE_MIRROR=false
fi

function download_data() {
	CONNECTIONS=4
	DOWNLOAD_URL="https://receita.economia.gov.br/orientacao/tributaria/cadastros/cadastro-nacional-de-pessoas-juridicas-cnpj/dados-publicos-cnpj"
	FILE_URLS=$(wget --quiet --no-check-certificate -O - "$DOWNLOAD_URL" \
		| grep --color=no DADOS_ABERTOS_CNPJ \
		| grep --color=no ".zip" \
		| sed 's/.*"http:/http:/; s/".*//' \
		| sort)
	MIRROR_URL="https://data.brasil.io/mirror/socios-brasil"

	for url in $FILE_URLS; do
		if $USE_MIRROR; then
			url="$MIRROR_URL/$(basename $url)"
		fi
		time aria2c --auto-file-renaming=false --continue=true -s $CONNECTIONS -x $CONNECTIONS --dir=data/download "$url"
	done
}

function extract_data() {
	time python extract_dump.py data/output/ data/download/DADOS_ABERTOS_CNPJ*.zip
}

function extract_holdings() {
	time python extract_holdings.py data/output/socio.csv.gz data/output/empresa-socia.csv.gz
}

function extract_cnae() {
	for versao in "1.0" "1.1" "2.0" "2.1" "2.2" "2.3"; do
		filename="data/output/cnae-$versao.csv"
		rm -rf "$filename"
		time scrapy runspider \
			-s RETRY_HTTP_CODES="500,503,504,400,404,408" \
			-s HTTPCACHE_ENABLED=true \
			--loglevel=INFO \
			-a versao="$versao" \
			-o "$filename" \
			cnae.py
		gzip "$filename"
	done
}

download_data
extract_data
extract_holdings
extract_cnae
