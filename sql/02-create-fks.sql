-- CNPJ
ALTER TABLE cnae_cnpj ADD CONSTRAINT fk_cnae_cnpj_cnpj FOREIGN KEY (cnpj) REFERENCES empresa (cnpj);
ALTER TABLE empresa_socia ADD CONSTRAINT fk_empresa_socia_cnpj FOREIGN KEY (cnpj) REFERENCES empresa (cnpj);
--ALTER TABLE empresa_socia ADD CONSTRAINT fk_empresa_socia_cnpj_cpf_do_socio FOREIGN KEY (cnpj_cpf_do_socio) REFERENCES empresa (cnpj);
ALTER TABLE socio ADD CONSTRAINT fk_socio_cnpj FOREIGN KEY (cnpj) REFERENCES empresa (cnpj);

-- CNAE
ALTER TABLE empresa ADD CONSTRAINT fk_empresa_cnae_fiscal FOREIGN KEY (cnae_fiscal) REFERENCES cnae (id);
ALTER TABLE cnae_cnpj ADD CONSTRAINT fk_cnae_cnpj_cnae FOREIGN KEY (cnae) REFERENCES cnae (id);
