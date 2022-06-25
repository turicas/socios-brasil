DROP TABLE IF EXISTS regime_tributario_uuid;
CREATE TABLE regime_tributario_uuid AS
  SELECT
    company_uuid(r.cnpj) AS empresa_uuid,
    r.ano::smallint AS ano,
    REGEXP_REPLACE(r.cnpj, '[./-]', '', 'g') AS cnpj,
    r.forma_tributacao,
    CASE
      WHEN r.municipio IS NULL OR r.municipio = 'NULL' THEN NULL
      ELSE r.municipio
    END AS municipio,
    CASE
      WHEN r.uf IS NULL OR r.uf = 'NULL' THEN NULL
      ELSE r.uf
    END AS uf
  FROM regime_tributario AS r;

-- TODO: quando consertarem os municípios que estão com UF incorreta, adicionar
-- codigo_municipio usando:
--    LEFT JOIN municipio_uf AS m
--      ON r.uf = m.uf AND slug(r.municipio) = slug(m.nome);

CREATE INDEX idx_regime_tributario_id ON regime_tributario_uuid (empresa_uuid);
CREATE INDEX idx_regime_tributario_cnpj ON regime_tributario_uuid (cnpj);
