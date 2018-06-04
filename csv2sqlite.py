#!/usr/bin/env python3
import csv
import io
import lzma
import sqlite3

from rows.plugins.utils import ipartition


drop_sql = 'DROP TABLE IF EXISTS socios'
create_sql = '''CREATE TABLE IF NOT EXISTS socios (
    cnpj TEXT,
    razao_social TEXT,
    codigo_tipo_socio INT,
    tipo_socio TEXT,
    cpf_cnpj_socio TEXT,
    codigo_qualificacao_socio INT,
    qualificacao_socio TEXT,
    nome_socio TEXT,
    uf TEXT
);'''
header = ('cnpj', 'razao_social', 'codigo_tipo_socio', 'tipo_socio',
          'cpf_cnpj_socio', 'codigo_qualificacao_socio', 'qualificacao_socio',
          'nome_socio', 'uf')
placeholders = ', '.join('?' for _ in header)
header_names = ', '.join(header)
insert_sql = f'INSERT INTO socios ({header_names}) VALUES ({placeholders})'

connection = sqlite3.Connection('output/socios-brasil.sqlite')
cursor = connection.cursor()
cursor.execute(drop_sql)
cursor.execute(create_sql)

with lzma.open('output/socios-brasil.csv.xz') as fobj:
    fobj = io.TextIOWrapper(fobj, encoding='utf-8')
    counter = 0
    batch_size = 100000
    for batch in ipartition(csv.DictReader(fobj), batch_size):
        cursor.executemany(
            insert_sql,
            [[row[field] for field in header] for row in batch],
        )

        counter += len(batch)
        if counter % 10000 == 0:
            print(counter)
    print(counter)

connection.commit()
