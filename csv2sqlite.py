#!/usr/bin/env python3
import csv
import io
import lzma
import sqlite3

from rows.plugins.utils import ipartition


tables = {
    'empresas': {
        'filename': 'output/empresas-brasil.csv.xz',
        'fields': {
            'cnpj': 'TEXT',
            'razao_social': 'TEXT',
        },
    },
    'empresas_socias': {
        'filename': 'output/empresas-socias.csv.xz',
        'fields': {
            'cnpj': 'TEXT',
            'razao_social': 'TEXT',
            'cnpj_socia': 'TEXT',
            'qualificacao_socia': 'TEXT',
            'razao_social_socia': 'TEXT',
        },
    },
    'socios': {
        'filename': 'output/socios-brasil.csv.xz',
        'fields': {
            'cnpj': 'TEXT',
            'razao_social': 'TEXT',
            'codigo_tipo_socio': 'INT',
            'tipo_socio': 'TEXT',
            'cpf_cnpj_socio': 'TEXT',
            'codigo_qualificacao_socio': 'INT',
            'qualificacao_socio': 'TEXT',
            'nome_socio': 'TEXT',
            'uf': 'TEXT',
        },
    },
}


def convert_file(filename, connection, tablename, fields, input_encoding):

    print(f'Converting {filename}...')
    drop_sql = f'DROP TABLE IF EXISTS {tablename}'
    fields_text = ', '.join(f'{field_name} {field_type}'
                            for field_name, field_type in fields.items())
    create_sql = f'CREATE TABLE IF NOT EXISTS {tablename} ({fields_text});'
    header = list(fields.keys())
    placeholders = ', '.join('?' for _ in header)
    header_names = ', '.join(header)
    insert_sql = f'INSERT INTO {tablename} ({header_names}) VALUES ({placeholders})'

    cursor = connection.cursor()
    cursor.execute(drop_sql)
    cursor.execute(create_sql)

    with lzma.open(filename) as fobj:
        fobj = io.TextIOWrapper(fobj, encoding=input_encoding)
        counter = 0
        batch_size = 100000
        for batch in ipartition(csv.DictReader(fobj), batch_size):
            cursor.executemany(
                insert_sql,
                [[row[field] for field in header] for row in batch],
            )

            counter += len(batch)
            if counter % 10000 == 0:
                print(f'  {counter}', end='\r')
        print(f'  {counter} - done.')

    connection.commit()


if __name__ == '__main__':
    connection = sqlite3.Connection('output/socios-brasil.sqlite')
    input_encoding = 'utf-8'
    for tablename, data in tables.items():
        fields = data['fields']
        filename = data['filename']
        convert_file(filename, connection, tablename, fields, input_encoding)
