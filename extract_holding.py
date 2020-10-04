from argparse import ArgumentParser
from csv import DictReader
from pathlib import Path

import rows
from rows.utils import CsvLazyDictWriter, open_compressed
from tqdm import tqdm

QUALIFICACAO_SOCIO = {row.codigo: row.descricao for row in rows.import_from_csv("qualificacao-socio.csv")}


def convert_socio(row):
    codigo_qualificacao = int(row["codigo_qualificacao_socio"])
    return {
        "holding_cnpj": row["cnpj_cpf_do_socio"],
        "holding_razao_social": row["nome_socio"],
        "cnpj": row["cnpj"],
        "razao_social": "",
        "codigo_qualificacao_socia": codigo_qualificacao,
        "qualificacao_socia": QUALIFICACAO_SOCIO.get(codigo_qualificacao, None),
    }


def convert_empresa(row):
    return {
        "cnpj": row["cnpj"],
        "razao_social": row["razao_social"],
    }


def filter_csv(input_filename, filter_function, convert_function, progress=True):
    fobj_reader = open_compressed(input_filename, mode="r")
    csv_reader = DictReader(fobj_reader)
    if progress:
        csv_reader = tqdm(csv_reader, desc=f"Reading {Path(input_filename).name}")
    for row in csv_reader:
        if filter_function(row):
            yield convert_function(row)
    fobj_reader.close()


def main():
    parser = ArgumentParser()
    parser.add_argument("socio_filename")
    parser.add_argument("empresa_filename")
    parser.add_argument("output_filename")
    args = parser.parse_args()

    holdings_it = filter_csv(
        args.socio_filename,
        lambda row: row["identificador_de_socio"] == "1",
        convert_function=convert_socio,
        progress=True,
    )
    holdings = {row["cnpj"]: row for row in holdings_it}

    cnpjs = set(holdings.keys())
    company_names_it = filter_csv(
        args.empresa_filename, lambda row: row["cnpj"] in cnpjs, convert_function=convert_empresa, progress=True,
    )
    company_names = {row["cnpj"]: row["razao_social"] for row in company_names_it}

    fobj_writer = open_compressed(args.output_filename, mode="w")
    csv_writer = CsvLazyDictWriter(fobj_writer)
    for holding in tqdm(holdings.values(), desc="Writting output file"):
        holding["razao_social"] = company_names.get(holding["cnpj"], "")
        csv_writer.writerow(holding)
    fobj_writer.close()


if __name__ == "__main__":
    main()
