DROP TABLE IF EXISTS empresa CASCADE;
CREATE TABLE empresa AS
  SELECT
    e."uuid",
    CASE
      WHEN p.pessoa_cpf IS NOT NULL THEN person_uuid(p.pessoa_cpf, p.pessoa_nome)
      ELSE NULL
    END AS pessoa_uuid,
    p.pessoa_cpf,
    p.pessoa_nome,

    e.codigo_natureza_juridica,
    e.codigo_qualificacao_responsavel,
    e.codigo_porte,
    m.codigo::smallint AS ente_responsavel_codigo_municipio,

    e.capital_social,
    e.cnpj_raiz,
    e.razao_social,
    e.ente_responsavel_uf
  FROM (
    SELECT
      company_uuid(cnpj_raiz || '000100') AS "uuid",

      codigo_natureza_juridica::smallint AS codigo_natureza_juridica,
      codigo_qualificacao_responsavel::smallint AS codigo_qualificacao_responsavel,
      codigo_porte::smallint AS codigo_porte,

      REPLACE(capital_social, ',', '.')::decimal AS capital_social,
      cnpj_raiz,
      razao_social,
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
      AND codigo_natureza_juridica <> 0
  ) AS e
  LEFT JOIN LATERAL (
    SELECT
      REGEXP_REPLACE(REGEXP_REPLACE(TRIM(e.razao_social), '.* ([0-9.-]{11,14})$', '\1'), '[.-]+', '', 'g') AS pessoa_cpf,
      TRIM(REGEXP_REPLACE(TRIM(e.razao_social), '[,-]? ?(CPF)? ?(N ?|NO ?)?[:.-]? ?[0-9.-]{11,14}$', ' ')) AS pessoa_nome
    WHERE
      e.codigo_natureza_juridica = 2135
      AND TRIM(e.razao_social) ~ ' [0-9.-]{11,14}$'
  ) AS p
    -- Filtra apenas CPFs com 11 dígitos para evitar o uso de CPFs possivelmente incorretos
    ON p.pessoa_cpf ~ '^[0-9]{11}$' AND p.pessoa_nome <> ''
  LEFT JOIN municipio_uf AS m
    ON e.ente_responsavel_uf = m.uf AND e.ente_responsavel_municipio = m.nome;

CREATE INDEX idx_empresa_uuid ON empresa ("uuid");
CREATE INDEX idx_empresa_mei ON empresa (pessoa_uuid);
