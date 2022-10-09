DROP TABLE IF EXISTS empresa;
CREATE TABLE empresa AS
  SELECT
    e."uuid",
    e.cnpj_raiz,
    e.razao_social,
    e.codigo_natureza_juridica,
    e.codigo_qualificacao_responsavel,
    e.capital_social,
    e.codigo_porte,
    e.ente_responsavel_uf,
    m.codigo AS ente_responsavel_codigo_municipio
  FROM (
    SELECT
      company_uuid(cnpj_raiz || '000100') AS "uuid",
      cnpj_raiz,
      razao_social,
      codigo_natureza_juridica::smallint AS codigo_natureza_juridica,
      codigo_qualificacao_responsavel::smallint AS codigo_qualificacao_responsavel,
      REPLACE(capital_social, ',', '.')::decimal AS capital_social,
      codigo_porte::smallint AS codigo_porte,
      CASE
        WHEN ente_federativo IS NULL THEN NULL
        WHEN NOT ente_federativo LIKE '% - %' THEN sigla_uf(ente_federativo)
        WHEN ente_federativo LIKE '% - %' THEN REGEXP_REPLACE(ente_federativo, '.*- ', '')
        ELSE ente_federativo -- não deveria acontecer
      END AS ente_responsavel_uf,
      CASE
        WHEN ente_federativo IS NULL THEN NULL
        WHEN NOT ente_federativo LIKE '% - %' THEN NULL
        WHEN ente_federativo LIKE '% - %' THEN REGEXP_REPLACE(ente_federativo, ' - .*', '')
        ELSE ente_federativo -- não deveria acontecer
      END AS ente_responsavel_municipio
    FROM empresa_orig
    WHERE
      razao_social IS NOT NULL
      OR codigo_natureza_juridica = 0
  ) AS e
    LEFT JOIN municipio_uf AS m
      ON e.ente_responsavel_uf = m.uf AND e.ente_responsavel_municipio = m.nome;

CREATE INDEX idx_empresa_uuid ON empresa ("uuid");
