#!/usr/bin/env python3
"""
Extrai os dados do dump do QSA da Receita Federal

Dentro dos arquivos ZIP existe apenas um arquivo do tipo fixed-width file,
contendo registros de diversas tabelas diferentes. O script descompacta sob
demanda o ZIP e, conforme vai lendo os registros contidos, cria os arquivos de
saída, em formato CSV. Você deve especificar o arquivo de entrada e o diretório
onde ficarão os CSVs de saída (que por padrão ficam compactados também, em
gzip, para diminuir o tempo de escrita e economizar espaço em disco).
"""

from argparse import ArgumentParser
from decimal import Decimal
from io import TextIOWrapper
from pathlib import Path
from zipfile import ZipFile

import rows
from rows.fields import slug
from rows.plugins.utils import ipartition
from rows.utils import CsvLazyDictWriter, open_compressed
from tqdm import tqdm

# Fields to delete/clean in some cases so we don't expose personal information
FIELDS_TO_DELETE = {
    "1": ("codigo_pais", "correio_eletronico", "nome_pais"),  # Company
    "2": ("codigo_pais", "nome_pais"),  # Partner
}
FIELDS_TO_CLEAR_MEI = (
    "complemento",
    "ddd_fax",
    "ddd_telefone_1",
    "ddd_telefone_2",
    "descricao_tipo_logradouro",
    "logradouro",
    "numero",
)
ONE_CENT = Decimal("0.01")


def clear_company_name(name):
    """Remove CPF from company name (useful to remove sensitive data from MEI)

    >>> clear_company_name('FALANO DE TAL 12345678901')
    'FALANO DE TAL'
    >>> clear_company_name('FALANO DE TAL CPF 12345678901')
    'FALANO DE TAL'
    >>> clear_company_name('FALANO DE TAL - CPF 12345678901')
    'FALANO DE TAL'
    >>> clear_company_name('123456')
    '123456'
    """
    if name.isdigit():  # Weird name, but not an "eupresa"
        return name

    words = name.split()
    if words[-1].isdigit() and len(words[-1]) == 11:  # Remove CPF (numbers)
        words.pop()
    if words[-1].upper() == "CPF":  # Remove CPF (word)
        words.pop()
    if words[-1] == "-":
        words.pop()
    return " ".join(words).strip()


def censor(row_type, row):
    """Remove sensitive information from row (in place)"""

    # Delete some fields
    if row_type in FIELDS_TO_DELETE:
        for field_name in FIELDS_TO_DELETE[row_type]:
            if field_name in row:
                del row[field_name]

    # Clear/modify some fields
    if row_type == "1" and row["opcao_pelo_mei"] == "1":  # "eupresa"
        for field_name in FIELDS_TO_CLEAR_MEI:
            row[field_name] = ""
        # Clear CPF from razao_social/nome_fantasia
        if row["razao_social"].split()[-1].isdigit():
            row["razao_social"] = clear_company_name(row["razao_social"])
        if row["nome_fantasia"] and row["nome_fantasia"].split()[-1].isdigit():
            row["nome_fantasia"] = clear_company_name(row["nome_fantasia"])


class ParsingError(ValueError):
    def __init__(self, line, error):
        super().__init__()
        self.line = line
        self.error = error


def clear_email(email):
    """
    >>> clear_email('-') is None
    True
    >>> clear_email('.') is None
    True
    >>> clear_email('0') is None
    True
    >>> clear_email('0000000000000000000000000000000000000000') is None
    True
    >>> clear_email('N/TEM') is None
    True
    >>> clear_email('NAO POSSUI') is None
    True
    >>> clear_email('NAO TEM') is None
    True
    >>> clear_email('NT') is None
    True
    >>> clear_email('S/N') is None
    True
    >>> clear_email('XXXXXXXX') is None
    True
    >>> clear_email('________________________________________') is None
    True
    >>> clear_email('n/t') is None
    True
    >>> clear_email('nao tem') is None
    True
    """

    clean = email.lower().replace("/", "").replace("_", "")
    if len(set(clean)) < 3 or clean in ("nao tem", "n tem", "ntem", "nao possui", "nt"):
        return None
    return email


def read_header(filename):
    """Read a CSV file which describes a fixed-width file

    The CSV must have the following columns:

    - name (final field name)
    - size (fixed size of the field, in bytes)
    - start_column (column in the fwf file where the fields starts)
    - type ("A" for text, "N" for int)
    """

    table = rows.import_from_csv(filename)
    table.order_by("start_column")
    header = []
    for row in table:
        row = dict(row._asdict())
        row["field_name"] = slug(row["name"])
        row["start_index"] = row["start_column"] - 1
        row["end_index"] = row["start_index"] + row["size"]
        header.append(row)
    return header


def transform_empresa(row):
    """Transform row of type company"""

    row["correio_eletronico"] = clear_email(row["correio_eletronico"])

    if row["opcao_pelo_simples"] in ("", "0", "6", "8"):
        row["opcao_pelo_simples"] = "0"
    elif row["opcao_pelo_simples"] in ("5", "7"):
        row["opcao_pelo_simples"] = "1"
    else:
        raise ValueError(f"Opção pelo Simples inválida: {row['opcao_pelo_simples']} (CNPJ: {row['cnpj']})")

    if row["opcao_pelo_mei"] in ("N", ""):
        row["opcao_pelo_mei"] = "0"
    elif row["opcao_pelo_mei"] == "S":
        row["opcao_pelo_mei"] = "1"
    else:
        raise ValueError(f"Opção pelo MEI inválida: {row['opcao_pelo_mei']} (CNPJ: {row['cnpj']})")

    if set(row["nome_fantasia"]) == set(["0"]):
        row["nome_fantasia"] = ""

    if row["capital_social"] is not None:
        row["capital_social"] = Decimal(row["capital_social"]) * ONE_CENT

    return [row]


def transform_socio(row):
    """Transform row of type partner"""

    assert row["campo_desconhecido"] == ""  # Always empty
    del row["campo_desconhecido"]

    if row["nome_representante_legal"] == "CPF INVALIDO":
        row["cpf_representante_legal"] = None
        row["nome_representante_legal"] = None
        row["codigo_qualificacao_representante_legal"] = None

    if row["cnpj_cpf_do_socio"] == "000***000000**":
        row["cnpj_cpf_do_socio"] = ""

    if row["identificador_de_socio"] == 2:  # Pessoa Física
        row["cnpj_cpf_do_socio"] = row["cnpj_cpf_do_socio"][-11:]

    # TODO: convert percentual_capital_social

    return [row]


def transform_cnae_secundaria(row):
    """Transform row of type CNAE"""

    cnaes = ["".join(digits) for digits in ipartition(row.pop("cnae"), 7) if set(digits) != set(["0"])]
    data = []
    for cnae in cnaes:
        new_row = row.copy()
        new_row["cnae"] = cnae
        data.append(new_row)

    return data


def parse_row(header, line):
    """Parse a fixed-width file line and returns a dict, based on metadata

    The `header` parameter is the return from `read_header`.
    Notes:
    1- There's no check whether all fields are parsed (this function trusts
       the `header` was created in the correct way).
    2- `line` is already decoded and since the input encoding is `latin1`, one
       character equals to one byte. If the input encoding does not have this
       characteristic then this function needs to be changed.
    """
    line = line.replace("\x00", " ").replace("\x02", " ")
    row = {}
    for field in header:
        field_name = field["field_name"]
        value = line[field["start_index"] : field["end_index"]].strip()

        if field_name == "filler":
            if set(value) not in (set(), {"9"}):
                raise ParsingError(line=line, error="Wrong filler")
            continue  # Do not save `filler`
        elif field_name == "tipo_de_registro":
            continue  # Do not save row type (will be saved in separate files)
        elif field_name == "fim":
            if value.strip() != "F":
                raise ParsingError(line=line, error="Wrong end")
            continue  # Do not save row end mark
        elif field_name in ("indicador_full_diario", "tipo_de_atualizacao"):
            continue  # These fields are usually useless

        if field_name.startswith("data_") and value:
            if len(str(value)) > 8:
                raise ParsingError(line=line, error="Wrong date size")
            value = f"{value[:4]}-{value[4:6]}-{value[6:8]}"
            if value == "0000-00-00":
                value = ""
        elif field["type"] == "N" and "*" not in value:
            try:
                value = int(value) if value else None
            except ValueError:
                raise ParsingError(line=line, error=f"Cannot convert {repr(value)} to int")

        row[field_name] = value

    return row


def extract_files(
    filenames,
    header_definitions,
    transform_functions,
    output_writers,
    error_filename,
    input_encoding="latin1",
    censorship=True,
):
    """Extract files from a fixed-width file containing more than one row type

    `filenames` is expected to be a list of ZIP files having only one file
    inside each. The file is read and metadata inside `fobjs` is used to parse
    it and save the output files.
    """
    error_fobj = open_compressed(error_filename, mode="w", encoding="latin1")
    error_writer = CsvLazyDictWriter(error_fobj)

    for filename in filenames:
        # TODO: use another strategy to open this file (like using rows'
        # open_compressed when archive support is implemented)
        zf = ZipFile(filename)
        inner_filenames = zf.filelist
        assert len(inner_filenames) == 1, f"Only one file inside the zip is expected (got {len(inner_filenames)})"
        # XXX: The current approach of decoding here and then extracting
        # fixed-width-file data will work only for encodings where 1 character is
        # represented by 1 byte, such as latin1. If the encoding can represent one
        # character using more than 1 byte (like UTF-8), this approach will make
        # incorrect results.
        fobj = TextIOWrapper(zf.open(inner_filenames[0]), encoding=input_encoding)
        for line in tqdm(fobj, desc=f"Extracting {filename}"):
            row_type = line[0]
            try:
                row = parse_row(header_definitions[row_type], line)
            except ParsingError as exception:
                error_writer.writerow({"error": exception.error, "line": exception.line})
                continue
            data = transform_functions[row_type](row)
            for row in data:
                if censorship:  # Clear sensitive information
                    censor(row_type, row)
                output_writers[row_type].writerow(row)

        fobj.close()
        zf.close()

    error_fobj.close()


def main():
    base_path = Path(__file__).parent
    output_path = base_path / "data" / "output"
    error_filename = output_path / "errors.csv"

    parser = ArgumentParser()
    parser.add_argument("output_path", default=str(output_path))
    parser.add_argument("input_filenames", nargs="+")
    parser.add_argument("--no_censorship", action="store_true")
    args = parser.parse_args()

    input_encoding = "latin1"
    input_filenames = args.input_filenames
    output_path = Path(args.output_path)
    if not output_path.exists():
        output_path.mkdir(parents=True)
    error_filename = output_path / "error.csv.gz"
    censorship = not args.no_censorship

    row_types = {
        "0": {
            "header_filename": "headers/header.csv",
            "output_filename": output_path / "header.csv.gz",
            "transform_function": lambda row: [row],
        },
        "1": {
            "header_filename": "headers/empresa.csv",
            "output_filename": output_path / "empresa.csv.gz",
            "transform_function": transform_empresa,
        },
        "2": {
            "header_filename": "headers/socio.csv",
            "output_filename": output_path / "socio.csv.gz",
            "transform_function": transform_socio,
        },
        "6": {
            "header_filename": "headers/cnae_secundaria.csv",
            "output_filename": output_path / "cnae_secundaria.csv.gz",
            "transform_function": transform_cnae_secundaria,
        },
        "9": {
            "header_filename": "headers/trailler.csv",
            "output_filename": output_path / "trailler.csv.gz",
            "transform_function": lambda row: [row],
        },
    }
    header_definitions, output_writers, transform_functions = {}, {}, {}
    for row_type, data in row_types.items():
        header_definitions[row_type] = read_header(data["header_filename"])
        output_writers[row_type] = CsvLazyDictWriter(data["output_filename"])
        transform_functions[row_type] = data["transform_function"]
    extract_files(
        filenames=input_filenames,
        header_definitions=header_definitions,
        transform_functions=transform_functions,
        output_writers=output_writers,
        error_filename=error_filename,
        input_encoding=input_encoding,
        censorship=censorship,
    )


if __name__ == "__main__":
    main()
