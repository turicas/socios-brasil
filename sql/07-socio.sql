DROP TABLE IF EXISTS socio;
CREATE TABLE socio AS
  SELECT
    CASE
      WHEN codigo_identificador = 1 THEN company_uuid(cpf_cnpj)
      WHEN codigo_identificador = 2 THEN person_uuid(cpf_cnpj, nome)
      ELSE NULL
    END AS socio_uuid,
    -- TODO: Deveria criar `socio_uuid` quando não possuir `cpf_cnpj` ou `nome`?
    company_uuid(cnpj_raiz || '000100') AS empresa_uuid,
    cnpj_raiz,
    codigo_identificador::smallint AS codigo_identificador,
    UPPER(REPLACE(slug(nome), '-', ' ')) AS nome,
    -- TODO: O que fazer quando `nome` for NULL?
    -- TODO: Por que não manter nome original (talvez só limpar com TRIM)?
    cpf_cnpj,
    -- TODO: Trocar `cpf_cnpj` para NULL quando for '***000000**'`?
    codigo_qualificacao::smallint AS codigo_qualificacao,
    CASE
      WHEN data_entrada_sociedade IN ('00000000', '0') THEN NULL
      ELSE TO_DATE(data_entrada_sociedade, 'YYYYMMDD')
    END AS data_entrada_sociedade,
    codigo_pais::smallint AS codigo_pais,
    CASE
      WHEN representante IS NULL THEN NULL
      ELSE representante_cpf_cnpj
    END AS representante_cpf_cnpj,
    -- TODO: Trocar `representante_cpf_cnpj` para NULL quando for '***000000**'`?
    representante,
    CASE
      WHEN representante IS NULL THEN NULL
      ELSE representante_codigo_qualificacao::smallint
    END AS representante_codigo_qualificacao,
    CASE
      WHEN representante IS NULL THEN NULL
      ELSE CASE
        WHEN LENGTH(representante_cpf_cnpj) = 11 THEN person_uuid(representante_cpf_cnpj, representante)
        ELSE NULL -- Por enquanto, nenhum caso em que LENGTH() <> 11
      END
    END AS representante_uuid,
    CASE
      WHEN codigo_faixa_etaria = 0 THEN NULL
      ELSE codigo_faixa_etaria::smallint
    END AS codigo_faixa_etaria
  FROM socio_orig;

-- TODO: Renomear colunas
-- TODO: Separar índices

CREATE INDEX ON socio (socio_uuid, empresa_uuid);
CREATE INDEX ON socio (cpf_cnpj);
CREATE INDEX ON socio (cnpj_raiz);
