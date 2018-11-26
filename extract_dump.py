"""Extrai os dados do dump do QSA da Receita Federal

O arquivo de origem usado tem o nome "F.K032001K.D81106A.zip", mas pode ser
especificado qualquer arquivo de origem que siga o mesmo padrão - esse arquivo
não está disponível no site da Receita Federal (obtive pela Lei de Acesso à
Informação).

Dentro do arquivo zip existe apenas um arquivo do tipo fixed-width file,
contendo registros de diversas tabelas diferentes. O script descompacta sob
demanda o zip e, conforme vai lendo os registros contidos, cria os arquivos de
saída, em formato CSV. Você deve especificar o arquivo de entrada e o diretório
onde ficarão os CSVs de saída (que por padrão ficam compactados também, em
gzip, para diminuir o tempo de escrita e economizar espaço em disco).

Se você quer apenas acesso aos dados convertidos, você não precisa baixar
o arquivo de entrada e rodar o script (que pode levar horas) - procure por esse
dataset em https://brasil.io/ e baixe os dados:
    https://drive.google.com/open?id=1tOGB1mJZcF5V1SUS-YlPJF0-zdhfN1yd
"""

import argparse
import glob
import io
import pathlib
import zipfile

import rows
import rows.utils
from tqdm import tqdm


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
    return table


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
        field_name = rows.utils.slug(field.name)
        start_index = field.start_column - 1
        end_index = start_index + field.size
        value = line[start_index:end_index].strip()

        if field_name == "filler":
            if value.strip() not in ("", "9999999999999999"):
                print('ERROR parsing filler on line:')
                print(repr(line))
            continue
        elif field_name in ("tipo_de_registro", "tipo_do_registro"):
            row_type = value
            continue
        elif field_name in ("fim", "fim_registro", "fim_de_registro"):
            if value.strip() != "F":
                print('ERROR parsing end of row on line:')
                print(repr(line))
            continue

        if field_name.startswith("data_") and value:
            value = f"{value[:4]}-{value[4:6]}-{value[6:8]}"
        elif field.type == "N" and "*" not in value:
            value = int(value) if value else None

        row[field_name] = value

    if row_type == "1":  # empresa
        row["correio_eletronico"] = clear_email(row["correio_eletronico"])

    elif row_type == "2":  # socio
        del row["campo_desconhecido"]  # Always empty
        if row["nome_representante"] == "CPF INVALIDO":
            row["cpf_representante_legal"] = None
            row["nome_representante"] = None
            row["codigo_qualificacao_representante_legal"] = None

    elif row_type == "6":  # cnae
        if set(row["campo_desconhecido"]) == {"0"}:
            row["campo_desconhecido"] = None

    return row


def extract_files(filename, header_fobjs, output_writers, input_encoding="latin1"):
    """Extract files from a fixed-width file containing more than one row type

    The input filename is expected to be a zip file having only one file
    inside. The file is read and metadata inside `fobjs` is used to parse it
    and save the output files.
    """

    zf = zipfile.ZipFile(filename)
    filenames = zf.filelist
    assert (
        len(filenames) == 1
    ), f"Only one file inside the zip is expected (got {len(filenames)})"
    # TODO: read the contents as bytes, not str (decode just before writing -
    # slower but will work for files using an encoding where number of
    # characters is different from number of bytes).
    fobj = io.TextIOWrapper(zf.open(filenames[0]), encoding=input_encoding)
    for line in tqdm(fobj):
        row_type = line[0]
        row = parse_row(header_fobjs[row_type], line)
        output_writers[row_type].writerow(row)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("input_filename")
    parser.add_argument("output_path")
    args = parser.parse_args()

    input_encoding = "latin1"
    output_encoding = "utf-8"
    input_filename = args.input_filename
    output_path = pathlib.Path(args.output_path)
    if not output_path.exists():
        output_path.mkdir(parents=True)

    row_types = {
        "0": ("headers/header.csv", output_path / "header.csv.gz"),
        "1": ("headers/dados-cadastrais.csv", output_path / "empresa.csv.gz"),
        "2": ("headers/socios.csv", output_path / "socio.csv.gz"),
        "6": ("headers/cnaes.csv", output_path / "empresa-cnae.csv.gz"),
        "9": ("headers/trailler.csv", output_path / "trailler.csv.gz"),
    }
    header_fobjs, output_writers = {}, {}
    for row_type, (header_filename, output_filename) in row_types.items():
        header_fobjs[row_type] = read_header(header_filename)
        output_writers[row_type] = rows.utils.CsvLazyDictWriter(output_filename)
    extract_files(
        input_filename, header_fobjs, output_writers, input_encoding=input_encoding
    )


if __name__ == "__main__":
    main()
