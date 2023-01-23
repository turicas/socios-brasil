DROP TABLE IF EXISTS municipio_uf CASCADE;
CREATE TABLE municipio_uf AS
  WITH temp AS (
    SELECT DISTINCT
      codigo_municipio AS codigo,
      uf
    FROM estabelecimento
  )
  SELECT
    t.codigo AS codigo,
    t.uf AS uf,
    m.descricao AS nome,
    slug(m.descricao) AS nome_slug
  FROM temp AS t
    LEFT JOIN municipio_orig AS m
      ON t.codigo = m.codigo::smallint;

CREATE INDEX idx_municipio_uf_id ON municipio_uf (codigo);
CREATE INDEX idx_municipio_uf_id_slug ON municipio_uf (nome_slug, codigo);
CREATE INDEX idx_municipio_uf_pair ON municipio_uf (uf, nome);
