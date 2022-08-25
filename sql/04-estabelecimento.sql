DROP TABLE IF EXISTS estabelecimento_uuid;
CREATE TABLE estabelecimento_uuid AS
  SELECT
    company_uuid(cnpj_raiz) AS empresa_uuid,
    cnpj_raiz || cnpj_ordem || cnpj_dv AS cnpj,
    CASE
      WHEN matriz_filial = 1 THEN TRUE
      WHEN matriz_filial = 2 THEN FALSE
      ELSE NULL -- não deveria acontecer
    END AS matriz,
    nome_fantasia,
    codigo_situacao_cadastral::smallint AS codigo_situacao_cadastral,
    parse_date(data_situacao_cadastral) AS data_situacao_cadastral,
    codigo_motivo_situacao_cadastral::smallint AS codigo_motivo_situacao_cadastral,
    TRIM(cidade_exterior) AS cidade_exterior,
    codigo_pais::smallint AS codigo_pais,
    parse_date(data_inicio_atividade) AS data_inicio_atividade,
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
    CASE -- Conserta erro de preenchimento em cnpj_raiz = 05269598
      WHEN uf = 'BR' THEN 'RJ'
      ELSE uf
    END AS uf,
    (CASE -- Conserta erro de preenchimento cnpj_raiz = 39868640
      WHEN codigo_municipio = 6969 AND uf = 'PA' THEN 529
      ELSE codigo_municipio
    END)::smallint AS codigo_municipio,
    ddd_1, -- TODO: normalizar/limpar?
    telefone_1, -- TODO: normalizar/limpar?
    ddd_2, -- TODO: normalizar/limpar?
    telefone_2, -- TODO: normalizar/limpar?
    ddd_do_fax, -- TODO: normalizar/limpar?
    fax, -- TODO: normalizar/limpar?
    correio_eletronico, -- TODO: normalizar/limpar?
    situacao_especial, -- TODO: normalizar/limpar?
    parse_date(data_situacao_especial) AS data_situacao_especial
  FROM estabelecimento;

-- TODO: normalizar nomes de colunas

CREATE INDEX idx_estabelecimento_id ON estabelecimento_uuid (empresa_uuid);
CREATE INDEX idx_estabelecimento_cnpj ON estabelecimento_uuid (cnpj);
