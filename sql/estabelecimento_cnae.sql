DROP TABLE IF EXISTS estabelecimento_cnae;
CREATE TABLE estabelecimento_cnae AS
  SELECT
    e.cnpj,
    c.razao_social,
    e.nome_fantasia,
    e.cnae_principal,
    e.cnae_secundaria,
    e.uf,
    e.codigo_municipio,
    m.nome AS municipio,
    e.data_situacao_cadastral,
    e.codigo_situacao_cadastral,
    e.codigo_motivo_situacao_cadastral,
    e.data_inicio_atividade
  FROM estabelecimento AS e
    LEFT JOIN empresa AS c
      ON e.empresa_uuid = c.uuid
    LEFT JOIN municipio_uf AS m
      ON m.codigo = e.codigo_municipio;
