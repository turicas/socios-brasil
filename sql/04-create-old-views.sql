CREATE VIEW view_socios AS
	SELECT
		s.cnpj AS cnpj,
		e.razao_social AS razao_social,
		s.cnpj_cpf_do_socio AS cpf_cnpj_socio,
		s.nome_socio AS nome_socio,
		s.codigo_qualificacao_socio AS codigo_qualificacao_socio,
		s.identificador_de_socio AS codigo_tipo_socio,
		CASE
			WHEN s.identificador_de_socio = 1 THEN 'Pessoa Jurídica'
			WHEN s.identificador_de_socio = 2 THEN 'Pessoa Física'
			WHEN s.identificador_de_socio = 3 THEN 'Nome Exterior'
			ELSE NULL
		END AS tipo_socio,
		CASE
			WHEN s.codigo_qualificacao_socio = 1 THEN 'Acionista'
			WHEN s.codigo_qualificacao_socio = 2 THEN 'Acionista Controlador'
			WHEN s.codigo_qualificacao_socio = 3 THEN 'Acionista Diretor'
			WHEN s.codigo_qualificacao_socio = 4 THEN 'Acionista Presidente'
			WHEN s.codigo_qualificacao_socio = 5 THEN 'Administrador'
			WHEN s.codigo_qualificacao_socio = 6 THEN 'Administradora de consórcio de Empresas ou Grupo de Empresas'
			WHEN s.codigo_qualificacao_socio = 7 THEN 'Comissário'
			WHEN s.codigo_qualificacao_socio = 8 THEN 'Conselheiro de Administração'
			WHEN s.codigo_qualificacao_socio = 9 THEN 'Curador'
			WHEN s.codigo_qualificacao_socio = 10 THEN 'Diretor'
			WHEN s.codigo_qualificacao_socio = 11 THEN 'Interventor'
			WHEN s.codigo_qualificacao_socio = 12 THEN 'Inventariante'
			WHEN s.codigo_qualificacao_socio = 13 THEN 'Liquidante'
			WHEN s.codigo_qualificacao_socio = 14 THEN 'Mãe'
			WHEN s.codigo_qualificacao_socio = 15 THEN 'Pai'
			WHEN s.codigo_qualificacao_socio = 16 THEN 'Presidente'
			WHEN s.codigo_qualificacao_socio = 17 THEN 'Procurador'
			WHEN s.codigo_qualificacao_socio = 18 THEN 'Secretário'
			WHEN s.codigo_qualificacao_socio = 19 THEN 'Síndico (Condomínio)'
			WHEN s.codigo_qualificacao_socio = 20 THEN 'Sociedade Consorciada'
			WHEN s.codigo_qualificacao_socio = 21 THEN 'Sociedade Filiada'
			WHEN s.codigo_qualificacao_socio = 22 THEN 'Sócio'
			WHEN s.codigo_qualificacao_socio = 23 THEN 'Sócio Capitalista'
			WHEN s.codigo_qualificacao_socio = 24 THEN 'Sócio Comanditado'
			WHEN s.codigo_qualificacao_socio = 25 THEN 'Sócio Comanditário'
			WHEN s.codigo_qualificacao_socio = 26 THEN 'Sócio de Indústria'
			WHEN s.codigo_qualificacao_socio = 27 THEN 'Sócio Residente ou Domiciliado no Exterior'
			WHEN s.codigo_qualificacao_socio = 28 THEN 'Sócio-Gerente'
			WHEN s.codigo_qualificacao_socio = 29 THEN 'Sócio ou Acionista Incapaz ou Relativamente Incapaz (exceto menor)'
			WHEN s.codigo_qualificacao_socio = 30 THEN 'Sócio ou Acionista Menor (Assistido/Representado)'
			WHEN s.codigo_qualificacao_socio = 31 THEN 'Sócio Ostensivo'
			WHEN s.codigo_qualificacao_socio = 32 THEN 'Tabelião'
			WHEN s.codigo_qualificacao_socio = 33 THEN 'Tesoureiro'
			WHEN s.codigo_qualificacao_socio = 34 THEN 'Titular de Empresa Individual Imobiliária'
			WHEN s.codigo_qualificacao_socio = 35 THEN 'Tutor'
			WHEN s.codigo_qualificacao_socio = 36 THEN 'Gerente-Delegado'
			WHEN s.codigo_qualificacao_socio = 37 THEN 'Sócio Pessoa Jurídica Domiciliado no Exterior'
			WHEN s.codigo_qualificacao_socio = 38 THEN 'Sócio Pessoa Física Residente ou Domiciliado no Exterior'
			WHEN s.codigo_qualificacao_socio = 39 THEN 'Diplomata'
			WHEN s.codigo_qualificacao_socio = 40 THEN 'Cônsul'
			WHEN s.codigo_qualificacao_socio = 41 THEN 'Representante de Organização Internacional'
			WHEN s.codigo_qualificacao_socio = 42 THEN 'Oficial de Registro'
			WHEN s.codigo_qualificacao_socio = 43 THEN 'Responsável'
			WHEN s.codigo_qualificacao_socio = 44 THEN 'Sócio Participante'
			WHEN s.codigo_qualificacao_socio = 45 THEN 'Sócio Investidor'
			WHEN s.codigo_qualificacao_socio = 46 THEN 'Ministro de Estado das Relações Exteriores'
			WHEN s.codigo_qualificacao_socio = 47 THEN 'Sócio Pessoa Física Residente no Brasil'
			WHEN s.codigo_qualificacao_socio = 48 THEN 'Sócio Pessoa Jurídica Domiciliado no Brasil'
			WHEN s.codigo_qualificacao_socio = 49 THEN 'Sócio-Administrador'
			WHEN s.codigo_qualificacao_socio = 50 THEN 'Empresário'
			WHEN s.codigo_qualificacao_socio = 51 THEN 'Candidato a Cargo Político Eletivo'
			WHEN s.codigo_qualificacao_socio = 52 THEN 'Sócio com Capital'
			WHEN s.codigo_qualificacao_socio = 53 THEN 'Sócio sem Capital'
			WHEN s.codigo_qualificacao_socio = 54 THEN 'Fundador'
			WHEN s.codigo_qualificacao_socio = 55 THEN 'Sócio Comanditado Residente no Exterior'
			WHEN s.codigo_qualificacao_socio = 56 THEN 'Sócio Comanditário Pessoa Física Residente no Exterior'
			WHEN s.codigo_qualificacao_socio = 57 THEN 'Sócio Comanditário Pessoa Jurídica Domiciliado no Exterior'
			WHEN s.codigo_qualificacao_socio = 58 THEN 'Sócio Comanditário Incapaz'
			WHEN s.codigo_qualificacao_socio = 59 THEN 'Produtor Rural'
			WHEN s.codigo_qualificacao_socio = 60 THEN 'Cônsul Honorário'
			WHEN s.codigo_qualificacao_socio = 61 THEN 'Responsável Indigena'
			WHEN s.codigo_qualificacao_socio = 62 THEN 'Representante das Instituições Extraterritoriais'
			WHEN s.codigo_qualificacao_socio = 63 THEN 'Cotas em Tesouraria'
			WHEN s.codigo_qualificacao_socio = 64 THEN 'Administrador Judicial'
			WHEN s.codigo_qualificacao_socio = 65 THEN 'Titular Pessoa Física Residente ou Domiciliado no Brasil'
			WHEN s.codigo_qualificacao_socio = 66 THEN 'Titular Pessoa Física Residente ou Domiciliado no Exterior'
			WHEN s.codigo_qualificacao_socio = 67 THEN 'Titular Pessoa Física Incapaz ou Relativamente Incapaz (exceto menor)'
			WHEN s.codigo_qualificacao_socio = 68 THEN 'Titular Pessoa Física Menor (Assistido/Representado)'
			WHEN s.codigo_qualificacao_socio = 69 THEN 'Beneficiário Final'
			WHEN s.codigo_qualificacao_socio = 70 THEN 'Administrador Residente ou Domiciliado no Exterior'
			WHEN s.codigo_qualificacao_socio = 71 THEN 'Conselheiro de Administração Residente ou Domiciliado no Exterior'
			WHEN s.codigo_qualificacao_socio = 72 THEN 'Diretor Residente ou Domiciliado no Exterior'
			WHEN s.codigo_qualificacao_socio = 73 THEN 'Presidente Residente ou Domiciliado no Exterior'
			WHEN s.codigo_qualificacao_socio = 74 THEN 'Sócio-Administrador Residente ou Domiciliado no Exterior'
			WHEN s.codigo_qualificacao_socio = 75 THEN 'Fundador Residente ou Domiciliado no Exterior'
			WHEN s.codigo_qualificacao_socio = 76 THEN 'Protetor'
			WHEN s.codigo_qualificacao_socio = 77 THEN 'Vice-Presidente'
			WHEN s.codigo_qualificacao_socio = 78 THEN 'Titular Pessoa Jurídica Domiciliada no Brasil'
			WHEN s.codigo_qualificacao_socio = 79 THEN 'Titular Pessoa Jurídica Domiciliada no Exterior'
		END AS qualificacao_socio
	FROM data_sociosbrasil_socio AS s
	LEFT JOIN data_sociosbrasil_empresa AS e
	ON s.cnpj = e.cnpj;


CREATE VIEW view_holdings AS
	SELECT
		s.cnpj AS cnpj,
		s.razao_social AS razao_social,
		s.cpf_cnpj_socio AS cnpj_socia,
		s.nome_socio AS razao_social_socia,
		s.qualificacao_socio AS qualificacao_socia
	FROM view_socios AS s
	WHERE
		s.codigo_tipo_socio = 1;


CREATE VIEW view_empresas AS
	SELECT
		e.cnpj AS cnpj,
		e.razao_social AS razao_social,
		e.uf AS uf
	FROM data_sociosbrasil_empresa AS e;
