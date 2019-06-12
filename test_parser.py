from extract_dump import parse_row, read_header


headers = {
    "1": read_header("headers/empresa.csv"),
    "2": read_header("headers/socio.csv"),
    "6": read_header("headers/cnae-secundaria.csv"),
}


def test_empresa():
    data = "1F 000000000001911BANCO DO BRASIL SA                                                                                                                                    DIRECAO GERAL                                          022005110300                                                                                                                                2038196608016422100QUADRA              SAUN QUADRA 5 LOTE B TORRES I, II E III                     SN    ANDAR 1 A 16              SALA  101 A 1601          ANDAR 1 A 16              SALA  101 A 1601          ANDAR 1 A 16              SALA  101 A 1601          ASA NORTE                                         70040912DF9701BRASILIA                                          61  34939002            61  34931040SECEX@BB.COM.BR                                                                                                    10060000000000000500000000000000000N                                                                                                                                                                                                                                                                                  F\n"
    header = headers[data[0]]
    result = parse_row(header, data)
    expected = {
        "bairro": "ASA NORTE",
        "capital_social": 6000000000000,
        "cep": 70040912,
        "cnae_fiscal": 6422100,
        "cnpj": "00000000000191",
        "codigo_municipio": 9701,
        "codigo_natureza_juridica": 2038,
        "codigo_pais": "",
        "complemento": "ANDAR 1 A 16              SALA  101 A 1601          ANDAR 1 A 16              SALA  101 A 1601          ANDAR 1 A 16              SALA  101 A 1601",
        "correio_eletronico": "SECEX@BB.COM.BR",
        "data_exclusao_do_simples": "",
        "data_inicio_atividade": "1966-08-01",
        "data_opcao_pelo_simples": "",
        "data_situacao_cadastral": "2005-11-03",
        "data_situacao_especial": None,
        "ddd_fax": "61  34931040",
        "ddd_telefone_1": "61  34939002",
        "ddd_telefone_2": "",
        "descricao_tipo_logradouro": "QUADRA",
        "identificador_matriz_filial": 1,
        "logradouro": "SAUN QUADRA 5 LOTE B TORRES I, II E III",
        "motivo_situacao_cadastral": 0,
        "municipio": "BRASILIA",
        "nome_cidade_exterior": "",
        "nome_fantasia": "DIRECAO GERAL",
        "nome_pais": "",
        "numero": "SN",
        "opcao_pelo_mei": "N",
        "opcao_pelo_simples": "0",
        "porte": "05",
        "qualificacao_do_responsavel": 10,
        "razao_social": "BANCO DO BRASIL SA",
        "situacao_cadastral": 2,
        "situacao_especial": "",
        "uf": "DF",
    }
    assert result == expected


def test_socio():
    data = "2F 000000000001912MARCIO HAMILTON FERREIRA                                                                                                                              000***923641**100000020101117249ESTADOS UNIDOS                                                        ***000000**CPF INVALIDO                                                00                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        F\n"
    header = headers[data[0]]
    result = parse_row(header, data)
    expected = {
        "campo_desconhecido": "",
        "cnpj": "00000000000191",
        "cnpj_cpf_do_socio": "000***923641**",
        "codigo_pais": "249",
        "codigo_qualificacao_representante_legal": "00",
        "codigo_qualificacao_socio": "10",
        "cpf_representante_legal": "***000000**",
        "data_entrada_sociedade": "2010-11-17",
        "identificador_de_socio": 2,
        "nome_pais_socio": "ESTADOS UNIDOS",
        "nome_representante_legal": "CPF INVALIDO",
        "nome_socio": "MARCIO HAMILTON FERREIRA",
        "percentual_capital_social": 0,
    }
    assert result == expected


def test_cnae_secundaria():
    data = "6F 00000000000191649999900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         F\n"
    header = headers[data[0]]
    result = parse_row(header, data)
    expected = {
        "cnae": "649999900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
        "cnpj": "00000000000191",
    }

    assert result == expected
