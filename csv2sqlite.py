#!/usr/bin/env python3
import csv
import sqlite3


drop_sql = 'DROP TABLE IF EXISTS socios'
create_sql = '''CREATE TABLE IF NOT EXISTS socios (
    cnpj_empresa TEXT,
    nome_empresa TEXT,
    codigo_tipo_socio INT,
    tipo_socio TEXT,
    cpf_cnpj_socio TEXT,
    codigo_qualificacao_socio INT,
    qualificacao_socio TEXT,
    nome_socio TEXT,
    unidade_federativa TEXT
);'''
header = ('cnpj_empresa', 'nome_empresa', 'codigo_tipo_socio', 'tipo_socio',
          'cpf_cnpj_socio', 'codigo_qualificacao_socio', 'qualificacao_socio',
          'nome_socio', 'unidade_federativa')
placeholders = ', '.join('?' for _ in header)
header_names = ', '.join(header)
insert_sql = f'INSERT INTO socios ({header_names}) VALUES ({placeholders})'

connection = sqlite3.Connection('output/socios-brasil.sqlite')
cursor = connection.cursor()
cursor.execute(drop_sql)
cursor.execute(create_sql)

with open('output/socios-brasil.csv.xz', encoding='utf8') as fobj:
    for counter, row in enumerate(csv.DictReader(fobj), start=1):
        data = [row[field] for field in header]
        cursor.execute(insert_sql, data)

        if counter % 10000 == 0:
            print(counter)

connection.commit()
