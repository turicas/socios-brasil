CREATE OR REPLACE FUNCTION sigla_uf(value TEXT)
RETURNS TEXT AS $$
BEGIN
  RETURN CASE
    WHEN value = 'ACRE' THEN 'AC'
    WHEN value = 'ALAGOAS' THEN 'AL'
    WHEN value = 'AMAPA' THEN 'AP'
    WHEN value = 'AMAZONAS' THEN 'AM'
    WHEN value = 'BAHIA' THEN 'BA'
    WHEN value = 'CEARA' THEN 'CE'
    WHEN value = 'DISTRITO FEDERAL' THEN 'DF'
    WHEN value = 'ESPIRITO SANTO' THEN 'ES'
    WHEN value = 'GOIAS' THEN 'GO'
    WHEN value = 'MARANHAO' THEN 'MA'
    WHEN value = 'MATO GROSSO DO SUL' THEN 'MS'
    WHEN value = 'MATO GROSSO' THEN 'MT'
    WHEN value = 'MINAS GERAIS' THEN 'MG'
    WHEN value = 'PARA' THEN 'PA'
    WHEN value = 'PARAIBA' THEN 'PB'
    WHEN value = 'PARANA' THEN 'PR'
    WHEN value = 'PERNAMBUCO' THEN 'PE'
    WHEN value = 'PIAUI' THEN 'PI'
    WHEN value = 'RIO DE JANEIRO' THEN 'RJ'
    WHEN value = 'RIO GRANDE DO NORTE' THEN 'RN'
    WHEN value = 'RIO GRANDE DO SUL' THEN 'RS'
    WHEN value = 'RONDONIA' THEN 'RO'
    WHEN value = 'RORAIMA' THEN 'RR'
    WHEN value = 'SANTA CATARINA' THEN 'SC'
    WHEN value = 'SAO PAULO' THEN 'SP'
    WHEN value = 'SERGIPE' THEN 'SE'
    WHEN value = 'TOCANTINS' THEN 'TO'
    WHEN value = 'UNIÃO' THEN 'BR'
    ELSE value
  END;
END; $$ LANGUAGE 'plpgsql' IMMUTABLE;
