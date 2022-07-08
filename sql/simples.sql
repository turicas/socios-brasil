DROP TABLE IF EXISTS simples_uuid;
CREATE TABLE simples_uuid AS
  SELECT
    company_uuid(cnpj_raiz) AS empresa_uuid,
    cnpj_raiz,
    CASE
      WHEN opcao_simples = 'S' THEN TRUE
      WHEN opcao_simples = 'N' THEN FALSE
      ELSE NULL
    END AS opcao_simples,
    CASE
      WHEN data_opcao_simples IN ('00000000', '0') THEN NULL
      ELSE TO_DATE(data_opcao_simples, 'YYYYMMDD')
    END AS data_opcao_simples,
    CASE
      WHEN data_exclusao_simples IN ('00000000', '0') THEN NULL
      ELSE TO_DATE(data_exclusao_simples, 'YYYYMMDD')
    END AS data_exclusao_simples,
    CASE
      WHEN opcao_mei = 'S' THEN TRUE
      WHEN opcao_mei = 'N' THEN FALSE
      ELSE NULL
    END AS opcao_mei,
    CASE
      WHEN data_opcao_mei IN ('00000000', '0') THEN NULL
      ELSE TO_DATE(data_opcao_mei, 'YYYYMMDD')
    END AS data_opcao_mei,
    CASE
      WHEN data_exclusao_mei IN ('00000000', '0') THEN NULL
      ELSE TO_DATE(data_exclusao_mei, 'YYYYMMDD')
    END AS data_exclusao_mei
  FROM simples;

CREATE INDEX ON simples_uuid (empresa_uuid);


CREATE INDEX ON empresa (cnpj_raiz);
CREATE VIEW IF NOT EXISTS empresa_simples AS
  SELECT
    s.*,
    e.razao_social,
    e.codigo_natureza_juridica,
    e.codigo_qualificacao_responsavel,
    e.capital_social,
    e.codigo_porte,
    e.ente_federativo
    e.*,
    opcao_simples,
    data_opcao_simples,
    data_exclusao_simples,
    opcao_mei,
    data_opcao_mei,
    data_exclusao_mei
  FROM empresa AS e
    LEFT JOIN simples_uuid AS s
      ON e.cnpj_raiz = s.cnpj_raiz;

-- TODO: renomear colunas