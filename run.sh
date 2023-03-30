#!/bin/bash

set -e

DOWNLOAD_PATH=data/download
OUTPUT_PATH=data/output
mkdir -p $DOWNLOAD_PATH $OUTPUT_PATH

if [[ ! "$DATABASE_URL" ]]; then
	echo "ERROR - set $DATABASE_URL"
	exit 1
fi

echo "Downloading..."
python download.py

echo "Loading downloaded data into PostgreSQL..."
python import_rfb.py \
	--database-url=$DATABASE_URL \
	--drop-if-exists \
	"data/download/$(ls --color=no -tr data/download | tail -1)" \
	all

for filename in urlid 01-functions 02-estabelecimento 03-municipio 04-empresa 05-simples 06-regime_tributario 07-socio; do
	filename="sql/${filename}.sql"
	echo "Executing ${filename}"
	time cat "$filename" | psql "$DATABASE_URL"
done
