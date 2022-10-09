DROP TABLE IF EXISTS municipio_uf;
CREATE TABLE municipio_uf AS
  WITH temp AS (
    SELECT DISTINCT
      (CASE -- Conserta erro de preenchimento cnpj_raiz = 39868640
        WHEN codigo_municipio = 6969 AND uf = 'PA' THEN 529
        ELSE codigo_municipio
      END)::smallint AS codigo,
      CASE -- Conserta erro de preenchimento em cnpj_raiz = 05269598
        WHEN uf = 'BR' THEN 'RJ'
        ELSE uf
      END AS uf
    FROM estabelecimento_orig
  )
  SELECT
    t.codigo::smallint AS codigo,
    t.uf AS uf,
    m.descricao AS nome
  FROM temp AS t
    LEFT JOIN municipio AS m
      ON t.codigo = m.codigo;

CREATE INDEX idx_municipio_uf_id ON municipio_uf (codigo);
CREATE INDEX idx_municipio_uf_pair ON municipio_uf (uf, nome);
