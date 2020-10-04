#!/bin/bash

set -e

DOWNLOAD_PATH=data/download
OUTPUT_PATH=data/output
mkdir -p $DOWNLOAD_PATH $OUTPUT_PATH

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
		time aria2c \
			--auto-file-renaming=false \
			--continue=true \
			-s $CONNECTIONS \
			-x $CONNECTIONS \
			--dir="$DOWNLOAD_PATH" \
			"$url"
	done
}

function extract_data() {
	time python extract_dump.py $OUTPUT_PATH $DOWNLOAD_PATH/DADOS_ABERTOS_CNPJ*.zip
	time python extract_cnae_cnpj.py $OUTPUT_PATH/{empresa,cnae_secundaria,cnae_cnpj}.csv.gz
}

function extract_holding() {
	time python extract_holding.py $OUTPUT_PATH/{socio,empresa,holding}.csv.gz
}

function extract_cnae() {
	for versao in "1.0" "1.1" "2.0" "2.1" "2.2" "2.3"; do
		filename="$OUTPUT_PATH/cnae_$versao.csv"
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
extract_holding
extract_cnae
