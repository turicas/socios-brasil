DROP TABLE IF EXISTS socio_uuid;
CREATE TABLE socio_uuid AS
  SELECT
    CASE
      WHEN codigo_identificador = 1 THEN company_uuid(cpf_cnpj)
      WHEN codigo_identificador = 2 THEN person_uuid(cpf_cnpj, nome)
      ELSE NULL
    END AS socio_uuid,
    company_uuid(cnpj_raiz) AS empresa_uuid,
    cnpj_raiz,
    codigo_identificador,
    UPPER(REPLACE(slug(nome), '-', ' ')) AS nome,
    cpf_cnpj,
    codigo_qualificacao,
    TO_DATE(data_entrada_sociedade, 'YYYYMMDD') AS data_entrada_sociedade,
    codigo_pais,
    CASE
      WHEN representante IS NULL THEN NULL
      ELSE representante_cpf_cnpj
    END AS representante_cpf_cnpj,
    representante,
    CASE
      WHEN representante IS NULL THEN NULL
      ELSE representante_codigo_qualificacao
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
      ELSE codigo_faixa_etaria
    END AS codigo_faixa_etaria
  FROM socio;

-- TODO: renomear colunas
-- TODO: separar índices

CREATE INDEX ON socio_uuid (socio_uuid, empresa_uuid);
CREATE INDEX ON socio_uuid (cpf_cnpj);
CREATE INDEX ON socio_uuid (cnpj_raiz);
