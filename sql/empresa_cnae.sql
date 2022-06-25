DROP TABLE IF EXISTS empresa_cnae;
CREATE TABLE empresa_cnae AS
  SELECT
    e.cnpj,
    c.razao_social,
    e.nome_fantasia,
    e.cnae_principal,
    e.cnae_secundaria,
    m.nome AS municipio,
    e.codigo_municipio,
    e.uf,
    e.data_situacao_cadastral,
    e.codigo_situacao_cadastral,
    e.codigo_motivo_situacao_cadastral,
    e.data_inicio_atividade
  FROM estabelecimento_uuid AS e
    LEFT JOIN empresa_uuid AS c
      ON e.empresa_uuid = c.empresa_uuid
    LEFT JOIN municipio_uf AS m
      ON m.codigo = e.codigo_municipio;
