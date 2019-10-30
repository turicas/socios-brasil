CREATE INDEX IF NOT EXISTS idx_socio_cnpj ON socio (cnpj);
CREATE INDEX IF NOT EXISTS idx_socio_documento_socio ON socio (cnpj_cpf_do_socio, cnpj);
CREATE INDEX IF NOT EXISTS idx_empresa_socia_cnpjs ON empresa_socia (cnpj, cnpj_cpf_do_socio);
CREATE INDEX IF NOT EXISTS idx_cnae_secundaria_cnpj ON cnae_secundaria (cnpj);
CREATE INDEX IF NOT EXISTS idx_cnae_cnpj_cnpj ON cnae_cnpj (cnpj);
CREATE INDEX IF NOT EXISTS idx_cnae_cnpj_cnae ON cnae_cnpj (cnae, primaria);
CREATE INDEX IF NOT EXISTS idx_cnae_id ON cnae (id);

CREATE INDEX IF NOT EXISTS idx_empresa_uf ON empresa (uf);
CREATE INDEX IF NOT EXISTS idx_empresa_mei_simples ON empresa (opcao_pelo_mei, opcao_pelo_simples);
CREATE INDEX IF NOT EXISTS idx_empresa_situacao_cadastral ON empresa (situacao_cadastral);

CREATE EXTENSION IF NOT EXISTS pg_trgm;  -- PostgreSQL-only
CREATE INDEX IF NOT EXISTS idx_trgm_socio_nome_socio ON socio USING gin (nome_socio gin_trgm_ops);
CREATE INDEX IF NOT EXISTS idx_trgm_empresa_razao_social ON empresa USING gin (razao_social gin_trgm_ops);
CREATE INDEX IF NOT EXISTS idx_trgm_empresa_nome_fantasia ON empresa USING gin (nome_fantasia gin_trgm_ops);
CREATE INDEX IF NOT EXISTS idx_trgm_cnae_descricao ON cnae USING gin (descricao_subclasse gin_trgm_ops);
