#!/bin/bash

SCHEMA_PATH="schema"
OUTPUT_PATH="data/output"

#time rows pgimport --schema="$SCHEMA_PATH/empresa.csv" "$OUTPUT_PATH/empresa.csv.gz" "$POSTGRESQL_URI" empresa
#time rows pgimport --schema="$SCHEMA_PATH/socio.csv" "$OUTPUT_PATH/empresa-socia.csv.gz" "$POSTGRESQL_URI" empresa_socia
#time rows pgimport --schema="$SCHEMA_PATH/socio.csv" "$OUTPUT_PATH/socio.csv.gz" "$POSTGRESQL_URI" socio
#time rows pgimport --schema="$SCHEMA_PATH/cnae-secundaria.csv" "$OUTPUT_PATH/cnae-secundaria.csv.gz" "$POSTGRESQL_URI" cnae_secundaria

schema="$SCHEMA_PATH/cnae.csv"
for filename in $OUTPUT_PATH/cnae-1*.csv* $OUTPUT_PATH/cnae-2*.csv*; do
    versao="$(basename $filename | sed 's/.csv.*//; s/cnae-//; s/\.//')"
    time rows pgimport --schema="$schema" "$filename" "$POSTGRESQL_URI" "cnae_$versao"
done

for filename in sql/*.sql; do
    echo $filename
    #time cat $filename | psql $POSTGRESQL_URI
done
