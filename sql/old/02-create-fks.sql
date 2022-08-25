-- CNPJ
ALTER TABLE cnae_cnpj ADD CONSTRAINT fk_cnae_cnpj_cnpj FOREIGN KEY (cnpj) REFERENCES empresa (cnpj);
ALTER TABLE holding ADD CONSTRAINT fk_holding_cnpj FOREIGN KEY (cnpj) REFERENCES empresa (cnpj);
ALTER TABLE holding ADD CONSTRAINT fk_holding_holding_cnpj FOREIGN KEY (holding_cnpj) REFERENCES empresa (cnpj);
ALTER TABLE socio ADD CONSTRAINT fk_socio_cnpj FOREIGN KEY (cnpj) REFERENCES empresa (cnpj);

-- CNAE
ALTER TABLE empresa ADD CONSTRAINT fk_empresa_cnae_fiscal FOREIGN KEY (cnae_fiscal) REFERENCES cnae (id);
ALTER TABLE cnae_cnpj ADD CONSTRAINT fk_cnae_cnpj_cnae FOREIGN KEY (cnae) REFERENCES cnae (id);
