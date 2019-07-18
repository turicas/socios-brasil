#!/bin/bash

mkdir -p data/output

for versao in "1.0" "1.1" "2.0" "2.1" "2.2" "2.3"; do
	filename="data/output/cnae-$versao.csv"
	rm -rf "$filename"
	time scrapy runspider \
		-s RETRY_HTTP_CODES="500,503,504,400,404,408" \
		--loglevel=INFO \
		-a versao="$versao" \
		-o "$filename" \
		cnae.py
done
