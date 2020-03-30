DROP TABLE IF EXISTS cnae_cnpj;
CREATE TABLE cnae_cnpj AS
    (SELECT cnpj, cnae_fiscal AS cnae, TRUE AS primaria FROM empresa)
    UNION
    (SELECT cnpj, cnae, FALSE AS primaria FROM cnae_secundaria);

DROP TABLE IF EXISTS cnae;
CREATE TABLE cnae AS SELECT * FROM cnae_23;
INSERT INTO cnae SELECT c22.* FROM cnae_22 AS c22 WHERE NOT EXISTS(SELECT * FROM cnae AS c WHERE c.id = c22.id);
INSERT INTO cnae SELECT c21.* FROM cnae_21 AS c21 WHERE NOT EXISTS(SELECT * FROM cnae AS c WHERE c.id = c21.id);
INSERT INTO cnae SELECT c20.* FROM cnae_20 AS c20 WHERE NOT EXISTS(SELECT * FROM cnae AS c WHERE c.id = c20.id);
INSERT INTO cnae SELECT c11.* FROM cnae_11 AS c11 WHERE NOT EXISTS(SELECT * FROM cnae AS c WHERE c.id = c11.id);
INSERT INTO cnae SELECT c10.* FROM cnae_10 AS c10 WHERE NOT EXISTS(SELECT * FROM cnae AS c WHERE c.id = c10.id);
