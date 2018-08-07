#!/usr/bin/env python3
import argparse
import csv
import datetime
import glob
import io
import lzma
import os
import stat
from multiprocessing import Pool
from pathlib import Path

import requests
import rows
from lxml.html import document_fromstring
from tqdm import tqdm


TIPOS_PESSOAS = {
    '1': 'Pessoa Jurídica',
    '2': 'Pessoa Física',
    '3': 'Nome Exterior',
}
QUALIFICACOES = {f'{row.codigo:02d}': row.descricao
                 for row in rows.import_from_csv('qualificacao-socio.csv')}
UNIDADES_FEDERATIVAS = {
    'acre': 'AC',
    'alagoas': 'AL',
    'amapá': 'AP',
    'amazonas': 'AM',
    'bahia': 'BA',
    'ceará': 'CE',
    'distrito federal': 'DF',
    'espírito santo': 'ES',
    'goiás': 'GO',
    'maranhão': 'MA',
    'mato grosso': 'MT',
    'mato grosso do sul': 'MS',
    'minas gerais': 'MG',
    'paraná': 'PR',
    'paraíba': 'PB',
    'pará': 'PA',
    'pernambuco': 'PE',
    'piauí': 'PI',
    'rio grande do norte': 'RN',
    'rio grande do sul': 'RS',
    'rio de janeiro': 'RJ',
    'rondônia': 'RO',
    'roraima': 'RR',
    'santa catarina': 'SC',
    'sergipe': 'SE',
    'são paulo': 'SP',
    'tocantins': 'TO',
}
HEADER_COMPANIES = ('cnpj', 'razao_social', 'uf')
HEADER_PARTNERS = (
    'cnpj', 'razao_social', 'codigo_tipo_socio', 'tipo_socio',
    'cpf_cnpj_socio', 'codigo_qualificacao_socio', 'qualificacao_socio',
    'nome_socio',
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


def create_download_script(filename=Path('data/download.sh'),
                           output_path=Path('data/output'),
                           download_path=Path('data/download')):
    if not filename.parent.exists():
        filename.parent.mkdir()
    if not output_path.exists():
        output_path.mkdir()

    links = discover_links()
    today = datetime.datetime.now()
    date = f'{today.year}-{today.month:02d}-{today.day:02d}'
    rows.export_to_csv(links, output_path / f'links_{date}.csv')

    with open(filename, mode='w', encoding='utf8') as fobj:
        fobj.write('#!/bin/sh\n')
        fobj.write(f'# Arquivo gerado em {today.year}-{today.month}-{today.day}\n')
        fobj.write('# Visite o site da Receita Federal para verificar se existem atualizações.\n\n')
        fobj.write('mkdir -p {}\n\n'.format(str(download_path)))
        for row in links:
            path = download_path / (row.uf + '.txt')
            fobj.write(f'wget -O "{path}" "{row.url}"\n')

    meta = os.stat(filename)
    os.chmod(filename, meta.st_mode | stat.S_IEXEC)


def parse_company(line):
    tipo, cnpj, nome_empresarial = line[:2], line[2:16], line[16:].strip()
    assert tipo == '01'
    return {
        'cnpj': cnpj,
        'razao_social': nome_empresarial,
    }


def _uf_from_filename(filename):
    uf = Path(filename).name.split('.')[0].split('-')[-1]
    if len(uf) > 2:
        uf = UNIDADES_FEDERATIVAS[uf.lower()]
    return uf.upper()


def read_companies_rfb(filename, encoding):
    uf = _uf_from_filename(filename)
    with open(filename, encoding=encoding) as fobj:
        for line in fobj:
            if line.startswith('01'):
                company = parse_company(line)
                company['uf'] = uf
                yield company


def parse_partner(line):
    tipo, cnpj, codigo_tipo_socio = line[:2], line[2:16], line[16:17]
    cpf_cnpj, codigo_qualificacao, nome = line[17:31], line[31:33], line[33:]
    assert tipo == '02'
    return {
        'cnpj': cnpj,
        'codigo_tipo_socio': codigo_tipo_socio,
        'tipo_socio': TIPOS_PESSOAS[codigo_tipo_socio],
        'cpf_cnpj_socio': cpf_cnpj.strip() or None,
        'codigo_qualificacao_socio': codigo_qualificacao.strip(),
        'qualificacao_socio': QUALIFICACOES.get(codigo_qualificacao, 'INVÁLIDA'),
        'nome_socio': nome.strip(),
    }


def read_partners(filename, encoding):
    with open(filename, encoding=encoding) as fobj:
        for line in fobj:
            if line.startswith('02'):
                yield parse_partner(line)


def extract_companies(filenames, output, input_encoding, output_encoding):
    with lzma.open(output, mode='w') as fobj:
        fobj = io.TextIOWrapper(fobj, encoding=output_encoding)
        writer = csv.DictWriter(
            fobj,
            fieldnames=HEADER_COMPANIES,
            lineterminator='\n',
        )
        writer.writeheader()
        company_names = {}
        for filename in filenames:
            companies = read_companies_rfb(filename, input_encoding)
            for company in tqdm(companies, desc=filename.name):
                company_names[company['cnpj']] = company['razao_social']
                writer.writerow(company)

    return company_names


def convert_file(filename, output_companies, output_partners,
                 input_encoding='iso-8859-15', output_encoding='utf8'):
    if not output_companies.parent.exists():
        output_companies.parent.mkdir()
    if not output_partners.parent.exists():
        output_partners.parent.mkdir()

    company_names = extract_companies(
        [filename],
        output_companies,
        input_encoding,
        output_encoding,
    )

    with lzma.open(output_partners, mode='w') as fobj:
        # Store the partners file, fixing some names based on company_names
        # dict. NOTE: this do not solve the whole problem (will only fix if the
        # partner company was registered in the same state).
        fobj = io.TextIOWrapper(fobj, encoding=output_encoding)
        writer = csv.DictWriter(
            fobj,
            fieldnames=HEADER_PARTNERS,
            lineterminator='\n',
        )
        writer.writeheader()
        for partner in read_partners(filename, encoding=input_encoding):
            partner['razao_social'] = company_names[partner['cnpj']]
            # If the partner is a company, try to fix its name
            if partner['tipo_socio'] != 'Pessoa Física':
                document = partner['cpf_cnpj_socio']
                partner['nome_socio'] = company_names.get(
                    document,
                    f"? {partner['qualificacao_socio']} ({document})"
                )
            writer.writerow(partner)


def convert_file_parallel(arg):
    filename, output_companies, output_partners = arg
    convert_file(filename, output_companies, output_partners)


def convert_all(wildcard, output_path):
    output_path = Path(output_path)
    if not output_path.exists():
        output_path.mkdir()

    args = []
    for filename in tqdm(sorted(glob.glob(wildcard), reverse=True)):
        uf = _uf_from_filename(filename)
        output_companies = output_path / Path(f'empresas-{uf}.csv.xz')
        output_partners = output_path / Path(f'socios-{uf}.csv.xz')
        args.append((Path(filename), output_companies, output_partners))

    with Pool() as pool:
        pool.map(convert_file_parallel, args)


def merge_partner_files(wildcard, output, input_encoding='utf-8',
                        output_encoding='utf-8'):
    output = Path(output)
    header = list(HEADER_PARTNERS)

    with lzma.open(output, mode='w') as fobj:
        fobj = io.TextIOWrapper(fobj, encoding=output_encoding)
        writer = csv.DictWriter(fobj, fieldnames=header, lineterminator='\n')
        writer.writeheader()

        for filename in tqdm(sorted(glob.glob(wildcard))):
            if 'links' in filename.lower() or 'brasil' in filename.lower():
                continue

            uf = _uf_from_filename(filename)
            with lzma.open(filename) as fobj_uf:
                fobj_uf = io.TextIOWrapper(fobj_uf, encoding=input_encoding)
                reader = csv.DictReader(fobj_uf)
                for row in reader:
                    writer.writerow(row)


def read_companies(filename, input_encoding):
    with lzma.open(filename) as fobj_read:
        fobj_read = io.TextIOWrapper(fobj_read, encoding=input_encoding)
        companies = {row['cnpj']: row['razao_social']
                     for row in csv.DictReader(fobj_read)}
    return companies


def fix_partner_file(filename, output, input_encoding='utf-8',
                     output_encoding='utf-8'):
    companies = read_companies(filename, input_encoding)

    header = list(HEADER_PARTNERS)
    with lzma.open(filename) as fobj_read, \
         lzma.open(output, mode='w') as fobj_write:
        fobj_read = io.TextIOWrapper(fobj_read, encoding=input_encoding)
        fobj_write = io.TextIOWrapper(fobj_write, encoding=output_encoding)
        reader = csv.DictReader(fobj_read)
        writer = csv.DictWriter(fobj_write, fieldnames=header,
                                lineterminator='\n')
        writer.writeheader()
        for row in tqdm(reader):
            document = row['cpf_cnpj_socio']
            if document in companies:
                row['nome_socio'] = companies[document]
            writer.writerow(row)


def extract_holdings(filename, output, input_encoding='utf-8',
                     output_encoding='utf-8'):

    header = ['cnpj', 'razao_social', 'cnpj_socia', 'qualificacao_socia',
              'razao_social_socia']
    with lzma.open(filename) as fobj_read, lzma.open(output, mode='w') as fobj_write:
        fobj_read = io.TextIOWrapper(fobj_read, encoding=input_encoding)
        fobj_write = io.TextIOWrapper(fobj_write, encoding=output_encoding)
        reader = csv.DictReader(fobj_read)
        writer = csv.DictWriter(fobj_write, fieldnames=header,
                                lineterminator='\n')
        writer.writeheader()
        for row in tqdm(reader):
            if row['tipo_socio'] != 'Pessoa Física':
                partner = {
                    'cnpj': row['cnpj'],
                    'razao_social': row['razao_social'],
                    'cnpj_socia': row['cpf_cnpj_socio'],
                    'qualificacao_socia': row['qualificacao_socio'],
                    'razao_social_socia': row['nome_socio'],
                }
                writer.writerow(partner)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument(
        'command',
        choices=['create-download-script', 'convert-all',
                 'merge-partner-files', 'extract-companies',
                 'convert-file', 'fix-partner-file', 'extract-holdings']
    )
    parser.add_argument('--input-filename')
    parser.add_argument('--output-filename')
    parser.add_argument('--output_companies_filename')
    parser.add_argument('--output_partners_filename')
    args = parser.parse_args()

    if args.command == 'create-download-script':
        print('Downloading links...', end='', flush=True)
        create_download_script()
        print(' done.')
        print('Run "data/download.sh" to download files, then run "convert-all".')

    elif args.command == 'convert-file':
        if None in (args.input_filename, args.output_companies_filename,
                    args.output_partners_filename):
            print('ERROR: options --input-filename, '
                  '--output_companies_filename '
                  'and --output_partners_filename are required.')
            exit(1)

        input_filename = Path(args.input_filename)
        output_companies_filename = Path(args.output_companies_filename)
        output_partners_filename = Path(args.output_partners_filename)
        print(f'Converting file "{input_filename}" into CSV... ', end='',
                flush=True)
        convert_file(
            input_filename,
            output_companies_filename,
            output_partners_filename,
        )
        print('done.')

    elif args.command == 'convert-all':
        print('Converting all files in "download"...')
        convert_all('data/download/*.txt', 'data/output')
        print('Done.')

    elif args.command == 'merge-partner-files':
        print('Merging partner files in "output"...')
        merge_partner_files('data/output/socios-*.csv.xz', 'data/output/pre-socios.csv.xz')

    elif args.command == 'fix-partner-file':
        input_filename = Path(args.input_filename or 'data/output/pre-socios.csv.xz')
        output_filename = Path(args.output_filename or 'data/output/socios.csv.xz')

        print(f'Fixing file "{input_filename}" into {output_filename}... ')
        fix_partner_file(input_filename, output_filename)

    elif args.command == 'extract-companies':
        if args.input_filename:
            filenames = [Path(args.input_filename)]
        else:
            filenames = [Path(filename)
                         for filename in glob.glob('data/download/*.txt')]
        output_filename = Path(args.output_filename or 'data/output/empresas.csv.xz')
        extract_companies(
            filenames,
            output_filename,
            'iso-8859-15',
            'utf-8',
        )

    elif args.command == 'extract-holdings':
        input_filename = Path(args.input_filename or 'data/output/socios.csv.xz')
        output_filename = Path(args.output_filename or 'data/output/holdings.csv.xz')

        print(f'Extracting holdings from "{input_filename}" into {output_filename}... ')
        extract_holdings(input_filename, output_filename)


if __name__ == '__main__':
    main()
