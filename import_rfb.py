"""Import downloaded data to PostgreSQL"""
import fnmatch
import warnings
import zipfile
from functools import cached_property
from pathlib import Path

from rows.plugins.postgresql import PostgresCopy, pg_execute_psql
from rows.utils import NotNullWrapper, ProgressBar, load_schema, subclasses

SCHEMA_PATH = Path(__file__).parent / "headers" / "novos"


class TableConfig:
    """Base class to handle table configurations during import"""

    filename_patterns: str  # Glob pattern for ZIP filename
    schema_filename: str  # Schema filename to use when importing
    has_header: bool  # Does the CSV file's first line is the header?
    name: str  # Table name to be imported
    inner_filename_pattern: str = None  # Glob pattern for filename inside ZIP
    # archive (if not specified, all files in archive are used)
    encoding: str = "iso-8859-15"  # Encoding for CSV
    dialect: str = "excel-semicolon"  # Dialect for CSV

    @classmethod
    def subclasses(cls):
        return {class_.name: class_ for class_ in subclasses(cls)}

    @cached_property
    def schema(self):
        return load_schema(str(SCHEMA_PATH / self.schema_filename))

    def filenames(self, zip_path):
        """List of zip files which matches this table's ZIP archive pattern"""
        zip_path = Path(zip_path)
        all_filenames = []
        for filename_pattern in self.filename_patterns:
            all_filenames.extend(zip_path.glob(filename_pattern))
        return sorted(set(all_filenames))

    def load(self, zip_path, database_url, unlogged=False, access_method=None, drop=False):
        """Load data into PostgreSQL database"""

        desc_import = f"Importing {self.name} (calculating size)"
        desc_drop = f"Dropping {self.name}"

        progress_bar = ProgressBar(pre_prefix=desc_drop if drop else desc_import, prefix="", unit="bytes")

        if drop:
            pg_execute_psql(database_url, f'DROP TABLE IF EXISTS "{self.name}"')
            progress_bar.prefix = progress_bar.description = desc_import

        # First, select all zip files and inner files to load
        filenames = self.filenames(zip_path)
        uncompressed_size, files_to_extract = 0, []
        for zip_filename in filenames:
            zf = zipfile.ZipFile(zip_filename)
            files_infos = [file_info for file_info in zf.filelist]
            if self.inner_filename_pattern:
                files_infos = [
                    file_info
                    for file_info in files_infos
                    if fnmatch.fnmatch(file_info.filename, self.inner_filename_pattern)
                ]
            if not files_infos:
                warnings.warn(f"Cannot match inner files in {zip_filename}", RuntimeWarning)
            files_to_extract.append((zf, files_infos))
            uncompressed_size += sum(file_info.file_size for file_info in files_infos)

        pgcopy = PostgresCopy(database_url)
        progress_bar.prefix = progress_bar.description = f"Importing {self.name} (ZIP 0/{len(files_to_extract)})"
        progress_bar.total = uncompressed_size
        rows_imported = 0
        for counter, (zf, files_infos) in enumerate(files_to_extract, start=1):
            progress_bar.prefix = progress_bar.description = f"Importing {self.name} (ZIP {counter}/{len(files_to_extract)})"
            for file_info in files_infos:
                # TODO: check if table already exists/has rows before importing?
                fobj = zf.open(file_info.filename)
                result = pgcopy.import_from_fobj(
                    fobj=NotNullWrapper(fobj),
                    table_name=self.name,
                    encoding=self.encoding,
                    dialect=self.dialect,
                    schema=self.schema,
                    has_header=self.has_header,
                    unlogged=unlogged,
                    access_method=access_method,
                    callback=progress_bar.update,
                )
                rows_imported += result["rows_imported"]
        progress_bar.description = f"[{self.name}] {rows_imported} rows imported"
        progress_bar.close()


class Empresa(TableConfig):
    filename_patterns = ("*EMPRECSV.zip", "Empresas*.zip")
    has_header = False
    name = "empresa_orig"
    schema_filename = "empresa.csv"


class Estabelecimento(TableConfig):
    filename_patterns = ("*ESTABELE.zip", "Estabelecimentos*.zip")
    has_header = False
    name = "estabelecimento_orig"
    schema_filename = "estabelecimento.csv"


class Simples(TableConfig):
    filename_patterns = ("*SIMPLES.CSV*zip", "Simples.zip")
    has_header = False
    name = "simples_orig"
    schema_filename = "simples.csv"


class Socio(TableConfig):
    filename_patterns = ("*SOCIOCSV.zip", "Socios*.zip")
    has_header = False
    name = "socio_orig"
    schema_filename = "socio.csv"


class MotivoSituacaoCadastral(TableConfig):
    filename_patterns = ("*MOTICSV.zip", "Motivos.zip")
    has_header = False
    name = "motivo_situacao_cadastral"
    schema_filename = "mapeamento.csv"


class Cnae(TableConfig):
    filename_patterns = ("*CNAECSV.zip", "Cnaes.zip")
    has_header = False
    name = "cnae"
    schema_filename = "mapeamento.csv"


class NaturezaJuridica(TableConfig):
    filename_patterns = ("*NATJUCSV.zip", "Naturezas.zip")
    has_header = False
    name = "natureza_juridica"
    schema_filename = "mapeamento.csv"


class Municipio(TableConfig):
    filename_patterns = ("*MUNICCSV.zip", "Municipios.zip")
    has_header = False
    name = "municipio"
    schema_filename = "mapeamento.csv"


class Pais(TableConfig):
    filename_patterns = ("*PAISCSV.zip", "Paises.zip")
    has_header = False
    name = "pais"
    schema_filename = "mapeamento.csv"


class QualificacaoSocio(TableConfig):
    filename_patterns = ("*QUALSCSV.zip", "Qualificacoes.zip")
    has_header = False
    name = "qualificacao_socio"
    schema_filename = "mapeamento.csv"


class RegimeTributario(TableConfig):
    # XXX: após a mudança do dataset para o dados.gov.br esse arquivo parou de
    # ser publicado e, com isso, a tabela `regime_tributario_orig` ficará
    # sempre vazia.
    dialect = "excel"
    filename_patterns = ("Dados Abertos Sítio RFB*.zip", )
    has_header = True
    inner_filename_pattern = "*.csv"
    name = "regime_tributario_orig"
    schema_filename = "regime_tributario.csv"


if __name__ == "__main__":
    import argparse
    import os
    import sys

    table_classes = TableConfig.subclasses()
    parser = argparse.ArgumentParser()
    parser.add_argument("--drop-if-exists", action="store_true", help="Drop table (if exists) before creating/importing data")
    parser.add_argument("--unlogged", action="store_true")
    parser.add_argument("--access-method", choices=["heap", "columnar"], default="heap")
    parser.add_argument("--database-url")
    parser.add_argument("download_path")
    parser.add_argument(
        "table",
        nargs="+",
        choices=["all"] + list(table_classes.keys()),
        help="Table to import (shortcut to all tables: 'all')",
    )
    args = parser.parse_args()

    database_url = args.database_url or os.environ.get("DATABASE_URL")
    if database_url is None:
        print("Error: you must specify either --database-url or set DATABASE_URL env var", file=sys.stderr)
        exit(1)

    tables_to_import = list(table_classes.keys()) if args.table[0].lower() == "all" else args.table
    for name, Table in table_classes.items():
        if name not in tables_to_import:
            continue

        table = Table()
        table.load(
            args.download_path,
            database_url,
            unlogged=args.unlogged,
            access_method=args.access_method,
            drop=args.drop_if_exists,
        )
