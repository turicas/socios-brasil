import argparse
import csv
from pathlib import Path

import rows
from tqdm import tqdm


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("empresa_csv_filename")
    parser.add_argument("cnae_secundaria_csv_filename")
    parser.add_argument("output_csv_filename")
    args = parser.parse_args()

    writer = rows.utils.CsvLazyDictWriter(args.output_csv_filename)

    fobj = rows.utils.open_compressed(args.empresa_csv_filename)
    reader = csv.DictReader(fobj)
    for row in tqdm(reader):
        writer.writerow({"cnpj": row["cnpj"], "cnae": row["cnae_fiscal"], "primaria": "t"})
    fobj.close()

    fobj = rows.utils.open_compressed(args.cnae_secundaria_csv_filename)
    reader = csv.DictReader(fobj)
    for row in tqdm(reader):
        writer.writerow({"cnpj": row["cnpj"], "cnae": row["cnae"], "primaria": "f"})
    fobj.close()

    writer.close()


if __name__ == "__main__":
    main()
