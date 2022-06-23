CREATE INDEX IF NOT EXISTS idx_empresa_cnpj_raiz ON empresa (cnpj_raiz);

CREATE TABLE empresa_cnae AS
  SELECT
    e.cnpj_raiz || e.cnpj_ordem || e.cnpj_dv AS cnpj,
    c.razao_social AS razao_social,
    e.nome_fantasia AS nome_fantasia,
    e.cnae_principal AS cnae_principal
  FROM estabelecimento AS e
    LEFT JOIN empresa AS c
      ON e.cnpj_raiz = c.cnpj_raiz;
