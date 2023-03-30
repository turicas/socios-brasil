DROP TABLE IF EXISTS regime_tributario;
CREATE TABLE regime_tributario AS
  SELECT
    company_uuid(r.cnpj) AS empresa_uuid,
    r.ano::smallint AS ano,
    REGEXP_REPLACE(r.cnpj, '[./-]', '', 'g') AS cnpj,
    REGEXP_REPLACE(r.cnpj_scp, '[./-]', '', 'g') AS cnpj_scp,
    r.forma_tributacao,
    qtd_escrituracoes::smallint AS qtd_escrituracoes
  FROM regime_tributario_orig AS r;

CREATE INDEX idx_regime_tributario_id ON regime_tributario (empresa_uuid);
CREATE INDEX idx_regime_tributario_cnpj ON regime_tributario (cnpj);