#!/usr/bin/env python3
import argparse
import csv
import datetime
import glob
import os
import stat
from pathlib import Path

import requests
import rows
from lxml.html import document_fromstring


TIPOS_PESSOAS = {
    '1': 'Pessoa Jurídica',
    '2': 'Pessoa Física',
    '3': 'Nome Exterior',
}
QUALIFICACOES = {f'{row.codigo:02d}': row.descricao
                 for row in rows.import_from_csv('qualificacao-socio.csv')}
HEADER = (
    'cnpj_empresa', 'nome_empresa', 'codigo_tipo_socio',
    'tipo_socio', 'cpf_cnpj_socio', 'codigo_qualificacao_socio',
    'qualificacao_socio', 'nome_socio'
)


def discover_links():
    url = 'http://idg.receita.fazenda.gov.br/orientacao/tributaria/cadastros/cadastro-nacional-de-pessoas-juridicas-cnpj/dados-abertos-do-cnpj'
    response = requests.get(url)
    tree = document_fromstring(response.text)
    header = ('uf', 'url')
    link_elements = tree.xpath('//a[contains(@href, "/consultas/download/")]')
    links = rows.import_from_dicts(
        [dict(zip(header, (elem.text, elem.attrib['href'])))
         for elem in link_elements]
    )
    return links


def create_download_script(filename='download.sh',
                           output_path=Path('output'),
                           download_path=Path('download')):
    if not download_path.exists():
        download_path.mkdir()
    if not output_path.exists():
        output_path.mkdir()

    links = discover_links()
    today = datetime.datetime.now()
    date = f'{today.year}-{today.month}-{today.day}'
    rows.export_to_csv(links, output_path / f'links_{date}.csv')

    with open(filename, mode='w', encoding='utf8') as fobj:
        fobj.write('#!/bin/sh\n')
        fobj.write(f'# Arquivo gerado em {today.year}-{today.month}-{today.day}\n')
        fobj.write('# Visite o site da Receita Federal para verificar se existem atualizações.\n\n')
        for row in links:
            path = download_path / (row.uf + '.txt')
            fobj.write(f'wget -O "{path}" "{row.url}"\n')

    meta = os.stat(filename)
    os.chmod(filename, meta.st_mode | stat.S_IEXEC)


def parse_company(line):
    tipo, cnpj, nome_empresarial = line[:2], line[2:16], line[16:]
    assert tipo == '01'
    return {
        'cnpj': cnpj,
        'nome_empresarial': nome_empresarial.strip(),
    }


def parse_partner(line):
    tipo, cnpj, codigo_tipo_socio = line[:2], line[2:16], line[16:17]
    cpf_cnpj, codigo_qualificacao, nome = line[17:31], line[31:33], line[33:]
    assert tipo == '02'
    return {
        'cnpj_empresa': cnpj,
        'codigo_tipo_socio': codigo_tipo_socio,
        'tipo_socio': TIPOS_PESSOAS[codigo_tipo_socio],
        'cpf_cnpj_socio': cpf_cnpj.strip() or None,
        'codigo_qualificacao_socio': codigo_qualificacao.strip(),
        'qualificacao_socio': QUALIFICACOES.get(codigo_qualificacao, 'INVÁLIDA'),
        'nome_socio': nome.strip(),
    }


def read_file(filename, encoding):
    with open(filename, encoding=encoding) as fobj:
        company = None
        for line in fobj:
            if line.startswith('01'):  # new company
                if company is not None:
                    for partner in partners:
                        assert partner['cnpj_empresa'] == company['cnpj']
                    # yield last company
                    yield {**company, 'partners': partners}

                company = parse_company(line)
                partners = []

            elif line.startswith('02'):
                partners.append(parse_partner(line))

            else:
                raise ValueError('Malformed file')

        yield {**company, 'partners': partners}


def convert_file(filename, output, input_encoding='iso-8859-15',
                 output_encoding='utf8'):
    with open(output, encoding=output_encoding, mode='w') as fobj:
        writer = csv.DictWriter(fobj, fieldnames=HEADER, lineterminator='\n')
        writer.writeheader()

        data = read_file(filename, encoding=input_encoding)
        for row in data:
            cnpj_empresa = row['cnpj']
            nome_empresa = row['nome_empresarial']
            for partner in row['partners']:
                partner.update({
                    'cnpj_empresa': cnpj_empresa,
                    'nome_empresa': nome_empresa,
                })
                writer.writerow(partner)


def convert_all(wildcard, output_path):
    output_path = Path(output_path)
    if not output_path.exists():
        output_path.mkdir()

    for filename in glob.glob(wildcard):
        uf = Path(filename).name.replace('.txt', '')
        output = output_path / Path(uf + '.csv')
        print(f'Converting {filename} into {output}...')
        convert_file(filename, output)


def merge_all(wildcard, output):
    output = Path(output)

    with open(output, mode='w', encoding='utf8') as fobj:
        writer = csv.DictWriter(fobj, fieldnames=HEADER, lineterminator='\n')
        writer.writeheader()

        for filename in glob.glob(wildcard):
            if 'links' in filename.lower() or 'brasil' in filename.lower():
                continue

            print(f'Merging {filename}...')
            with open(filename, encoding='utf8') as fobj_uf:
                reader = csv.DictReader(fobj_uf)
                for row in reader:
                    writer.writerow(row)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument(
        'command',
        choices=['create-download-script', 'convert-all', 'merge-all',
                'convert-file']
    )
    parser.add_argument('--input-filename')
    parser.add_argument('--output-filename')
    args = parser.parse_args()

    if args.command == 'create-download-script':
        print('Downloading links...', end='', flush=True)
        create_download_script()
        print(' done.')
        print('Run "download.sh" to download files, then run "convert-all".')

    elif args.command == 'convert-file':
        if args.input_filename is None or args.output_filename is None:
            print('ERROR: options --input-filename and --output-filename are needed.')
            exit(1)

        input_filename = Path(args.input_filename)
        output_filename = Path(args.output_filename)
        print(f'Converting file "{input_filename}" into CSV... ', end='',
                flush=True)
        convert_file(input_filename, output_filename)
        print('done.')

    elif args.command == 'convert-all':
        print('Converting all files in "download"...')
        convert_all('download/*.txt', 'output')
        print('Done.')

    elif args.command == 'merge-all':
        print('Merging all converted files in "output"...')
        merge_all('output/*.csv', 'output/Brasil.csv')
        print('Done.')


if __name__ == '__main__':
    main()
