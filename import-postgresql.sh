#!/bin/bash

SCHEMA_PATH="schema"
OUTPUT_PATH="data/output"

function import_table() {
	tablename="$1"

	echo "DROP TABLE IF EXISTS ${tablename};" | psql "$POSTGRESQL_URI"
	time rows pgimport \
		--schema="$SCHEMA_PATH/${tablename}.csv" \
		--input-encoding="utf-8" \
		--dialect="excel" \
		"$OUTPUT_PATH/${tablename}.csv.gz" \
		"$POSTGRESQL_URI" \
		"$tablename"
}

# Import main tables
import_table empresa
import_table cnae_cnpj
import_table socio
import_table holding

# Import CNAE tables
schema="cnae"
for filename in $OUTPUT_PATH/cnae_1*.csv* $OUTPUT_PATH/cnae_2*.csv*; do
    versao="$(basename $filename | sed 's/.csv.*//; s/cnae_//; s/\.//')"
    filename=$(basename $filename | sed 's/.csv.gz//')
    import_table $filename $schema "cnae_$versao"
done

## Execute SQL queries
for filename in sql/*.sql; do
    echo "Executing ${filename}..."
    time cat $filename | psql $POSTGRESQL_URI
done
