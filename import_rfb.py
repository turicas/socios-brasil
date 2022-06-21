import zipfile
from pathlib import Path

import rows
from rows.plugins.postgresql import PostgresCopy
from rows.utils import NotNullWrapper, ProgressBar, load_schema


def import_zipfiles(database_url, schema_path, zip_path):
    schema_glob = {
        "empresa.csv": "*EMPRECSV.zip",
        "estabelecimento.csv": "*ESTABELE.zip",
        "socio.csv": "*SOCIOCSV.zip",
        "simples.csv": "*SIMPLES.CSV*zip",
        # TODO: import "Dados Abertos Sítio RFB*.zip"
        # TODO: import "*CNAECSV.zip"
        # TODO: import "*MOTICSV.zip"
        # TODO: import "*MUNICCSV.zip"
        # TODO: import "*NATJUCSV.zip"
        # TODO: import "*PAISCSV.zip"
        # TODO: import "*QUALSCSV.zip"
    }
    encoding = "iso-8859-15"
    dialect = "excel-semicolon"
    skip_header = True
    unlogged = True
    schema_path = Path(schema_path)
    zip_path = Path(zip_path)
    pgcopy = PostgresCopy(database_url)

    for schema_name, zip_glob in schema_glob.items():
        table_name = schema_name.lower().replace(".csv", "").strip()
        schema = load_schema(str(schema_path / schema_name))

        filenames = sorted(zip_path.glob(zip_glob))
        for counter, zip_filename in enumerate(filenames, start=1):
            zf = zipfile.ZipFile(zip_filename)
            fobj = zf.open(zf.filelist[0].filename)

            progress_bar = ProgressBar(
                prefix=f"Importing {table_name} ({counter}/{len(filenames)})",
                unit="bytes",
            )
            result = pgcopy.import_from_fobj(
                fobj=NotNullWrapper(fobj),
                table_name=table_name,
                encoding=encoding,
                dialect=dialect,
                schema=schema,
                skip_header=skip_header,
                unlogged=unlogged,
                callback=progress_bar.update,
            )
            progress_bar.description = "{} rows imported".format(result["rows_imported"])
            progress_bar.close()


if __name__ == "__main__":
    import os

    current = Path(__file__).parent
    database_url = os.environ["DATABASE_URL"]
    schema_path = current / "headers" / "novos"
    zip_path = current / "data" / "download-2021-10-14"
    import_zipfiles(database_url, schema_path, zip_path)
