#!/bin/bash

set -e

time python3 socios.py create-download-script
time sh download.sh
time python3 socios.py convert-all
time python3 socios.py merge-partner-files
time python3 socios.py fix-partner-file
time python3 socios.py extract-companies
time python3 socios.py extract-company-company-partnerships
time python3 csv2sqlite.py
