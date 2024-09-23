#!/bin/bash

set -e

function log() {
	echo "[$(date --iso=seconds)] $@";
}

DOWNLOAD_PATH="data/download"
OUTPUT_PATH="data/output"
mkdir -p "$DOWNLOAD_PATH" "$OUTPUT_PATH"

if [[ ! "$DATABASE_URL" ]]; then
	echo "ERRO: variável DATABASE_URL não está definida"
	exit 1
fi

log "[download] Iniciando"
time python download.py
log "[download] Concluído"

log "[load] Iniciando"
time python import_rfb.py \
	--database-url=$DATABASE_URL \
	--drop-if-exists \
	"data/download/$(ls --color=no -tr data/download | tail -1)" \
	all
log "[load] Concluído"

log "[transform] Iniciando"
for filename in urlid 01-functions 02-estabelecimento 03-municipio 04-empresa 05-simples 06-regime_tributario 07-socio; do
	filename="sql/${filename}.sql"
	echo "Executing ${filename}"
	time cat "$filename" | psql "$DATABASE_URL"
done
log "[transform] Concluído"
