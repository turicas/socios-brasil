#!/bin/bash

set -e

cd /app

DOWNLOAD_SCRIPT=data/download.sh
EMPRESAS=data/output/empresas.csv.xz
HOLDINGS=data/output/holdings.csv.xz
SOCIOS=data/output/socios.csv.xz
DATABASE=data/output/socios-brasil.sqlite

time python3 socios.py create-download-script
time sh $DOWNLOAD_SCRIPT
time python3 socios.py convert-all
time python3 socios.py merge-partner-files
time python3 socios.py fix-partner-file
time python3 socios.py extract-companies
time python3 socios.py extract-holdings
time rows csv2sqlite $EMPRESAS $HOLDINGS $SOCIOS $DATABASE
