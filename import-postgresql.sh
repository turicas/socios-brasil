#!/bin/bash

SCHEMA_PATH="schema"
OUTPUT_PATH="data/output"

function import_table() {
	filename="$1"
	schema="$2"
	tablename="$3"

	time rows pgimport \
		--schema="$SCHEMA_PATH/${schema}.csv" \
		--input-encoding="utf-8" \
		--dialect="excel" \
		"$OUTPUT_PATH/${filename}.csv.gz" \
		"$POSTGRESQL_URI" \
		"$tablename"
}

# Import main tables
import_table empresa empresa empresa
import_table socio socio socio
import_table empresa-socia socio empresa_socia
import_table cnae-secundaria cnae-secundaria cnae_secundaria

# Import CNAE tables
schema="cnae"
for filename in $OUTPUT_PATH/cnae-1*.csv* $OUTPUT_PATH/cnae-2*.csv*; do
    versao="$(basename $filename | sed 's/.csv.*//; s/cnae-//; s/\.//')"
    filename=$(basename $filename | sed 's/.csv.gz//')
    import_table $filename $schema "cnae_$versao"
done

## Execute SQL queries
for filename in sql/*.sql; do
    echo "Executing ${filename}..."
    time cat $filename | psql $POSTGRESQL_URI
done
