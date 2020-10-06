import csv
import io
from itertools import chain

import requests
import rows


def clear_text(text):
    if text is None:
        return text
    text = text.replace("\t", " ").replace("\n", " ")
    while "  " in text:
        text = text.replace("  ", " ")
    return text


def extract_data():
    url = "https://www.receita.fazenda.gov.br/pessoajuridica/cnpj/tabelas/natjurqualificaresponsavel.htm"
    response = requests.get(url, verify=False)
    table_1 = rows.import_from_html(
        io.BytesIO(response.content), encoding=response.encoding, index=0, ignore_colspan=False
    )
    table_2 = rows.import_from_html(
        io.BytesIO(response.content), encoding=response.encoding, index=1, ignore_colspan=False
    )

    categoria, codigo_categoria = None, None
    for row in chain(table_1, table_2):
        row = {key: clear_text(value) for key, value in row._asdict().items()}

        codigo = row["codigo"]
        if ". " in codigo:
            categoria = codigo.title()
            split_index = categoria.find(". ")
            codigo_categoria, categoria = categoria[:split_index], categoria[split_index + 2 :]
            continue
        else:
            row["codigo"] = int(codigo.replace("-", ""))
        row["categoria"] = categoria
        row["codigo_categoria"] = codigo_categoria
        row["qualificacao"] = [item.strip() for item in row["qualificacao"].replace(" ou ", ", ").split(",")]

        yield row


if __name__ == "__main__":
    filename = "data/natureza-juridica.csv"

    writer = None
    with open(filename, mode="w") as fobj:
        for row in extract_data():
            row["qualificacao"] = "|".join(row["qualificacao"])
            if writer is None:
                writer = csv.DictWriter(fobj, fieldnames=list(row.keys()))
                writer.writeheader()
            writer.writerow(row)
