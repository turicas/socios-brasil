DROP TABLE IF EXISTS estabelecimento;
CREATE TABLE estabelecimento AS
  SELECT
    company_branch_uuid(RIGHT('00000000000000' || cnpj_raiz || cnpj_ordem || cnpj_dv, 14)) AS "uuid",
    company_uuid(RIGHT('00000000000000' || cnpj_raiz || cnpj_ordem || cnpj_dv, 14)) AS empresa_uuid,
    RIGHT('00000000000000' || cnpj_raiz || cnpj_ordem || cnpj_dv, 14) AS cnpj,
    CASE
      WHEN matriz_filial = 1 THEN TRUE
      WHEN matriz_filial = 2 THEN FALSE
      ELSE NULL -- não deveria acontecer
    END AS matriz,
    nome_fantasia,
    codigo_situacao_cadastral::smallint AS codigo_situacao_cadastral,
    parse_date(
      CASE
        WHEN data_situacao_cadastral = '2021221' THEN '20210221'
        ELSE data_situacao_cadastral
      END
    ) AS data_situacao_cadastral,
    codigo_motivo_situacao_cadastral::smallint AS codigo_motivo_situacao_cadastral,
    TRIM(cidade_exterior) AS cidade_exterior,
    codigo_pais::smallint AS codigo_pais,
    parse_date(
      CASE
        WHEN data_inicio_atividade = '2021221' THEN '20210221'
        ELSE data_inicio_atividade
      END
    ) AS data_inicio_atividade,
    cnae_principal,
    STRING_TO_ARRAY(cnae_secundaria, ',') AS cnae_secundaria,
    TRIM(tipo_logradouro) AS tipo_logradouro, -- TODO: normalizar?
    logradouro, -- TODO: normalizar/limpar?
    numero, -- TODO: normalizar/limpar?
    complemento, -- TODO: normalizar/limpar?
    bairro, -- TODO: normalizar/limpar?
    CASE
      WHEN cep IS NULL OR cep = '0' THEN NULL
      WHEN LENGTH(cep) = 8 THEN cep
      WHEN LENGTH(cep) = 7 THEN '0' || cep
      ELSE cep -- não deveria acontecer
    END AS cep,

    -- Conserta erro de preenchimento cnpj_raiz = 05269598, 39868640, 47515047
    CASE
      WHEN codigo_municipio = 6001 AND uf = 'BR' THEN 'RJ'
      WHEN codigo_municipio = 6969 AND uf = 'PA' THEN 'PA'
      WHEN codigo_municipio = 7107 AND uf = 'BA' THEN 'BA'
      ELSE uf
    END AS uf,
    (CASE
      WHEN codigo_municipio = 6001 AND uf = 'BR' THEN 6001
      WHEN codigo_municipio = 6969 AND uf = 'PA' THEN 529
      WHEN codigo_municipio = 7107 AND uf = 'BA' THEN 3873
      ELSE codigo_municipio
    END)::smallint AS codigo_municipio,
    TRIM(ddd_1) AS ddd_1, -- TODO: normalizar/limpar?
    TRIM(telefone_1) AS telefone_1, -- TODO: normalizar/limpar?
    TRIM(ddd_2) AS ddd_2, -- TODO: normalizar/limpar?
    TRIM(telefone_2) AS telefone_2, -- TODO: normalizar/limpar?
    TRIM(ddd_do_fax) AS ddd_fax, -- TODO: normalizar/limpar?
    TRIM(fax) AS fax, -- TODO: normalizar/limpar?
    TRIM(correio_eletronico) AS email, -- TODO: normalizar/limpar?
    situacao_especial, -- TODO: normalizar/limpar?
    parse_date(data_situacao_especial) AS data_situacao_especial
  FROM estabelecimento_orig;

-- TODO: normalizar nomes de colunas

CREATE INDEX idx_estabelecimento_uuid ON estabelecimento ("uuid");
CREATE INDEX idx_estabelecimento_empresa_uuid ON estabelecimento (empresa_uuid);
CREATE INDEX idx_estabelecimento_cnpj ON estabelecimento (cnpj);
