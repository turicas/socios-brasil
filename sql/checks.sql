-- Erro em municipio: não possui UF
-- A tabela anexa de municípios contém apenas os códigos e nomes dos
-- municípios, mas não a UF. 523 municípios possuem nomes repetidos (no total,
-- são 241 nomes) e o fato de não ter a UF dificulta em filtros e análises.


-- Erro em empresa: CNPJ raiz duplicado
SELECT cnpj_raiz, COUNT(*)
FROM empresa
GROUP BY cnpj_raiz
HAVING COUNT(*) > 1;
--  cnpj_raiz | count
-- -----------+-------
--  11895269  |     2


-- Erro em empresa: razão social/código da natureza jurídica nulos
SELECT *
FROM empresa
WHERE razao_social IS NULL OR codigo_natureza_juridica = 0;
-- -[ RECORD 1 ]-------------------+---------
-- cnpj_raiz                       | 07949190
-- razao_social                    |
-- codigo_natureza_juridica        | 0
-- codigo_qualificacao_responsavel | 0
-- capital_social                  | 0,00
-- codigo_porte                    |
-- ente_federativo                 |
-- -[ RECORD 2 ]-------------------+---------
-- cnpj_raiz                       | 11895269
-- razao_social                    |
-- codigo_natureza_juridica        | 0
-- codigo_qualificacao_responsavel | 0
-- capital_social                  | 0,00
-- codigo_porte                    |
-- ente_federativo                 |


-- Erro em regime_tributario: UF e Município com valor NULL (string)
SELECT *
FROM regime_tributario
WHERE uf = 'NULL' OR municipio = 'NULL';
--  ano  |        cnpj        | forma_tributacao | municipio |  uf
-- ------+--------------------+------------------+-----------+------
--  2020 | 01.162.285/0001-20 | ISENTA DO IRPJ   | NULL      | RS
--  2020 | 03.905.241/0001-78 | IMUNE DO IRPJ    | NULL      | RS
--  2020 | 04.578.375/0001-94 | ISENTA DO IRPJ   | NULL      | RS
--  2020 | 15.783.862/0001-05 | IMUNE DO IRPJ    | NULL      | RS
--  2020 | 19.960.594/0001-00 | ISENTA DO IRPJ   | NULL      | RS
--  2020 | 22.793.762/0001-25 | ISENTA DO IRPJ   | NULL      | RS
--  2020 | 29.333.891/0001-80 | ISENTA DO IRPJ   | NULL      | RS
--  2020 | 35.117.302/0001-29 | ISENTA DO IRPJ   | NULL      | RS
--  2020 | 35.834.448/0001-95 | IMUNE DO IRPJ    | NULL      | RS
--  2020 | 91.986.232/0001-16 | ISENTA DO IRPJ   | NULL      | RS
--  2019 | 01.162.285/0001-20 | ISENTA DO IRPJ   | NULL      | RS
--  2019 | 04.578.375/0001-94 | ISENTA DO IRPJ   | NULL      | RS
--  2019 | 04.880.553/0001-37 | ISENTA DO IRPJ   | NULL      | RS
--  2019 | 15.783.862/0001-05 | IMUNE DO IRPJ    | NULL      | RS
--  2019 | 19.960.594/0001-00 | IMUNE DO IRPJ    | NULL      | RS
--  2019 | 22.793.762/0001-25 | ISENTA DO IRPJ   | NULL      | RS
--  2019 | 29.333.891/0001-80 | ISENTA DO IRPJ   | NULL      | RS
--  2019 | 35.117.302/0001-29 | ISENTA DO IRPJ   | NULL      | RS
--  2019 | 35.834.448/0001-95 | IMUNE DO IRPJ    | NULL      | RS
--  2019 | 91.986.232/0001-16 | ISENTA DO IRPJ   | NULL      | RS
--  2018 | 01.162.285/0001-20 | ISENTA DO IRPJ   | NULL      | RS
--  2018 | 01.496.293/0001-02 | ISENTA DO IRPJ   | NULL      | RS
--  2018 | 03.905.241/0001-78 | ISENTA DO IRPJ   | NULL      | RS
--  2018 | 04.578.375/0001-94 | ISENTA DO IRPJ   | NULL      | RS
--  2018 | 04.880.553/0001-37 | ISENTA DO IRPJ   | NULL      | RS
--  2018 | 15.783.862/0001-05 | IMUNE DO IRPJ    | NULL      | RS
--  2018 | 22.154.352/0001-34 | IMUNE DO IRPJ    | NULL      | RS
--  2018 | 22.793.762/0001-25 | ISENTA DO IRPJ   | NULL      | RS
--  2018 | 29.333.891/0001-80 | ISENTA DO IRPJ   | NULL      | RS
--  2018 | 91.986.232/0001-16 | ISENTA DO IRPJ   | NULL      | RS
--  2017 | 01.162.285/0001-20 | ISENTA DO IRPJ   | NULL      | RS
--  2017 | 01.496.293/0001-02 | ISENTA DO IRPJ   | NULL      | RS
--  2017 | 03.905.241/0001-78 | ISENTA DO IRPJ   | NULL      | RS
--  2017 | 04.504.116/0001-19 | ISENTA DO IRPJ   | NULL      | RS
--  2017 | 15.783.862/0001-05 | IMUNE DO IRPJ    | NULL      | RS
--  2017 | 22.154.352/0001-34 | ISENTA DO IRPJ   | NULL      | RS
--  2017 | 22.793.762/0001-25 | ISENTA DO IRPJ   | NULL      | RS
--  2017 | 91.986.232/0001-16 | ISENTA DO IRPJ   | NULL      | RS
--  2016 | 01.162.285/0001-20 | ISENTA DO IRPJ   | NULL      | RS
--  2016 | 01.496.293/0001-02 | ISENTA DO IRPJ   | NULL      | RS
--  2016 | 03.905.241/0001-78 | ISENTA DO IRPJ   | NULL      | RS
--  2016 | 04.504.116/0001-19 | ISENTA DO IRPJ   | NULL      | RS
--  2016 | 04.578.375/0001-94 | ISENTA DO IRPJ   | NULL      | RS
--  2016 | 15.783.862/0001-05 | IMUNE DO IRPJ    | NULL      | RS
--  2016 | 19.960.594/0001-00 | ISENTA DO IRPJ   | NULL      | RS
--  2016 | 22.154.352/0001-34 | IMUNE DO IRPJ    | NULL      | RS
--  2016 | 22.793.762/0001-25 | ISENTA DO IRPJ   | NULL      | RS
--  2016 | 23.664.613/0001-29 | ISENTA DO IRPJ   | NULL      | NULL
--  2016 | 81.144.537/0001-27 | ISENTA DO IRPJ   | NULL      | NULL
--  2016 | 91.986.232/0001-16 | ISENTA DO IRPJ   | NULL      | RS
--  2015 | 01.156.699/0001-46 | ISENTA DO IRPJ   | NULL      | RS
--  2015 | 03.905.241/0001-78 | ISENTA DO IRPJ   | NULL      | RS
--  2015 | 04.504.116/0001-19 | ISENTA DO IRPJ   | NULL      | RS
--  2015 | 04.578.375/0001-94 | ISENTA DO IRPJ   | NULL      | RS
--  2015 | 22.793.762/0001-25 | ISENTA DO IRPJ   | NULL      | RS
--  2015 | 89.435.853/0001-60 | ISENTA DO IRPJ   | NULL      | RS
--  2014 | 00.683.630/0001-08 | IMUNE DO IRPJ    | NULL      | NULL
--  2020 | 00.844.081/0001-06 | LUCRO PRESUMIDO  | NULL      | RS
--  2020 | 01.710.739/0001-50 | LUCRO PRESUMIDO  | NULL      | RS
--  2020 | 21.082.464/0001-64 | LUCRO PRESUMIDO  | NULL      | RS
--  2020 | 21.245.614/0001-03 | LUCRO PRESUMIDO  | NULL      | RS
--  2020 | 28.809.040/0001-06 | LUCRO PRESUMIDO  | NULL      | RS
--  2020 | 35.158.824/0001-79 | LUCRO PRESUMIDO  | NULL      | RS
--  2020 | 89.831.788/0001-91 | LUCRO PRESUMIDO  | NULL      | RS
--  2019 | 00.844.081/0001-06 | LUCRO PRESUMIDO  | NULL      | RS
--  2019 | 01.710.739/0001-50 | LUCRO PRESUMIDO  | NULL      | RS
--  2019 | 01.781.252/0001-68 | LUCRO PRESUMIDO  | NULL      | MS
--  2019 | 01.781.252/0001-68 | LUCRO PRESUMIDO  | NULL      | NULL
--  2019 | 21.082.464/0001-64 | LUCRO PRESUMIDO  | NULL      | RS
--  2019 | 21.245.614/0001-03 | LUCRO PRESUMIDO  | NULL      | RS
--  2019 | 27.666.621/0001-65 | LUCRO PRESUMIDO  | NULL      | NULL
--  2019 | 28.492.896/0001-92 | LUCRO PRESUMIDO  | NULL      | RS
--  2019 | 28.809.040/0001-06 | LUCRO PRESUMIDO  | NULL      | RS
--  2019 | 35.158.824/0001-79 | LUCRO PRESUMIDO  | NULL      | RS
--  2019 | 89.831.788/0001-91 | LUCRO PRESUMIDO  | NULL      | RS
--  2018 | 00.844.081/0001-06 | LUCRO PRESUMIDO  | NULL      | RS
--  2018 | 01.710.739/0001-50 | LUCRO PRESUMIDO  | NULL      | RS
--  2018 | 02.247.166/0001-32 | LUCRO PRESUMIDO  | NULL      | RS
--  2018 | 07.158.386/0001-03 | LUCRO PRESUMIDO  | NULL      | RS
--  2018 | 11.010.403/0001-38 | LUCRO PRESUMIDO  | NULL      | RS
--  2018 | 21.082.464/0001-64 | LUCRO PRESUMIDO  | NULL      | RS
--  2018 | 21.245.614/0001-03 | LUCRO PRESUMIDO  | NULL      | RS
--  2018 | 27.259.351/0001-78 | LUCRO PRESUMIDO  | NULL      | RS
--  2018 | 28.492.896/0001-92 | LUCRO PRESUMIDO  | NULL      | RS
--  2018 | 28.809.040/0001-06 | LUCRO PRESUMIDO  | NULL      | RS
--  2018 | 89.831.788/0001-91 | LUCRO PRESUMIDO  | NULL      | RS
--  2017 | 01.710.739/0001-50 | LUCRO PRESUMIDO  | NULL      | RS
--  2017 | 02.247.166/0001-32 | LUCRO PRESUMIDO  | NULL      | RS
--  2017 | 07.158.386/0001-03 | LUCRO PRESUMIDO  | NULL      | RS
--  2017 | 11.010.403/0001-38 | LUCRO PRESUMIDO  | NULL      | RS
--  2017 | 15.635.613/0001-72 | LUCRO PRESUMIDO  | NULL      | RS
--  2017 | 21.082.464/0001-64 | LUCRO PRESUMIDO  | NULL      | RS
--  2017 | 21.245.614/0001-03 | LUCRO PRESUMIDO  | NULL      | RS
--  2017 | 24.213.308/0001-83 | LUCRO PRESUMIDO  | NULL      | NULL
--  2017 | 24.241.105/0001-09 | LUCRO PRESUMIDO  | NULL      | RS
--  2017 | 27.259.351/0001-78 | LUCRO PRESUMIDO  | NULL      | RS
--  2017 | 28.151.327/0001-83 | LUCRO PRESUMIDO  | NULL      | RS
--  2017 | 28.492.896/0001-92 | LUCRO PRESUMIDO  | NULL      | RS
--  2017 | 28.809.040/0001-06 | LUCRO PRESUMIDO  | NULL      | RS
--  2016 | 01.596.604/0001-05 | LUCRO PRESUMIDO  | NULL      | NULL
--  2016 | 01.710.739/0001-50 | LUCRO PRESUMIDO  | NULL      | RS
--  2016 | 02.247.166/0001-32 | LUCRO PRESUMIDO  | NULL      | RS
--  2016 | 07.158.386/0001-03 | LUCRO PRESUMIDO  | NULL      | RS
--  2016 | 09.070.286/0001-56 | LUCRO PRESUMIDO  | NULL      | RS
--  2016 | 11.010.403/0001-38 | LUCRO PRESUMIDO  | NULL      | RS
--  2016 | 14.292.595/0001-00 | LUCRO PRESUMIDO  | NULL      | RS
--  2016 | 15.635.613/0001-72 | LUCRO PRESUMIDO  | NULL      | RS
--  2016 | 21.082.464/0001-64 | LUCRO PRESUMIDO  | NULL      | RS
--  2016 | 21.245.614/0001-03 | LUCRO PRESUMIDO  | NULL      | RS
--  2016 | 24.241.105/0001-09 | LUCRO PRESUMIDO  | NULL      | RS
--  2015 | 00.844.081/0001-06 | LUCRO PRESUMIDO  | NULL      | RS
--  2015 | 01.710.739/0001-50 | LUCRO PRESUMIDO  | NULL      | RS
--  2015 | 02.247.166/0001-32 | LUCRO PRESUMIDO  | NULL      | RS
--  2015 | 09.070.286/0001-56 | LUCRO PRESUMIDO  | NULL      | RS
--  2015 | 10.792.725/0001-13 | LUCRO PRESUMIDO  | NULL      | RS
--  2015 | 11.010.403/0001-38 | LUCRO PRESUMIDO  | NULL      | RS
--  2015 | 14.292.595/0001-00 | LUCRO PRESUMIDO  | NULL      | RS
--  2015 | 21.082.464/0001-64 | LUCRO PRESUMIDO  | NULL      | RS
--  2015 | 21.245.614/0001-03 | LUCRO PRESUMIDO  | NULL      | RS
--  2015 | 89.831.788/0001-91 | LUCRO PRESUMIDO  | NULL      | RS
--  2014 | 05.491.719/0001-96 | LUCRO PRESUMIDO  | NULL      | NULL
--  2014 | 11.010.403/0001-38 | LUCRO PRESUMIDO  | NULL      | RS
--  2014 | 19.865.208/0001-00 | LUCRO PRESUMIDO  | NULL      | NULL
--  2014 | 21.082.464/0001-64 | LUCRO PRESUMIDO  | NULL      | RS
--  2014 | 94.802.402/0001-53 | LUCRO PRESUMIDO  | NULL      | RS
--  2020 | 28.492.896/0001-92 | LUCRO REAL       | NULL      | RS
--  2020 | 87.547.980/0001-25 | LUCRO REAL       | NULL      | RS
--  2020 | 94.802.402/0001-53 | LUCRO REAL       | NULL      | RS
--  2019 | 87.547.980/0001-25 | LUCRO REAL       | NULL      | RS
--  2019 | 94.802.402/0001-53 | LUCRO REAL       | NULL      | RS
--  2018 | 87.547.980/0001-25 | LUCRO REAL       | NULL      | RS
--  2018 | 94.802.402/0001-53 | LUCRO REAL       | NULL      | RS
--  2017 | 83.305.235/0001-19 | LUCRO REAL       | NULL      | NULL
--  2017 | 87.547.980/0001-25 | LUCRO REAL       | NULL      | RS
--  2017 | 94.802.402/0001-53 | LUCRO REAL       | NULL      | RS
--  2016 | 08.687.382/0001-85 | LUCRO REAL       | NULL      | NULL
--  2016 | 87.547.980/0001-25 | LUCRO REAL       | NULL      | RS
--  2014 | 02.366.978/0001-05 | LUCRO REAL       | NULL      | NULL
--  2014 | 87.547.980/0001-25 | LUCRO REAL       | NULL      | RS


-- Erro em estabelecimento: UF preenchido erroneamente como 'BR'
SELECT *
FROM estabelecimento
WHERE uf = 'BR';
-- -[ RECORD 1 ]--------------------+------------------
-- cnpj_raiz                        | 05269598
-- cnpj_ordem                       | 0001
-- cnpj_dv                          | 32
-- matriz_filial                    | 1
-- nome_fantasia                    |
-- codigo_situacao_cadastral        | 8
-- data_situacao_cadastral          | 20021231
-- codigo_motivo_situacao_cadastral | 1
-- cidade_exterior                  |
-- codigo_pais                      |
-- data_inicio_atividade            | 20020911
-- cnae_principal                   | 9492800
-- cnae_secundaria                  |
-- tipo_logradouro                  | RUA
-- logradouro                       | DAS MARRECAS
-- numero                           | 000027
-- complemento                      | 3: ANDAR - CENTRO
-- bairro                           |
-- cep                              | 20031120
-- uf                               | BR
-- codigo_municipio                 | 6001
-- ddd_1                            |
-- telefone_1                       |
-- ddd_2                            |
-- telefone_2                       |
-- ddd_do_fax                       |
-- fax                              |
-- correio_eletronico               | pcb@pcb.org.br
-- situacao_especial                |
-- data_situacao_especial           |


-- Erro em estabelecimento: código do município inválido para UF
SELECT cnpj_raiz, cnpj_ordem, cnpj_dv, cep, uf, codigo_municipio
FROM estabelecimento_orig
WHERE
	(codigo_municipio = '7107' AND uf <> 'SP')
	OR (codigo_municipio = '6001' AND uf <> 'RJ')
	OR (codigo_municipio = '6969' AND uf <> 'SP');
--  cnpj_raiz | cnpj_ordem | cnpj_dv |   cep    | uf | codigo_municipio
-- -----------+------------+---------+----------+----+------------------
--  05269598  | 0001       | 32      | 20031120 | BR |             6001
--  39868640  | 0001       | 53      | 68790000 | PA |             6969
--  47515047  | 0001       | 51      | 44571000 | BA |             7107


-- Erro em regime_tributario: UFs estão incorretas para diversos municípios
SELECT
	r.uf,
	r.municipio,
	COUNT(*) AS total
FROM regime_tributario_orig AS r
LEFT JOIN municipio_uf AS m
	ON r.uf = m.uf AND slug(r.municipio) = m.nome_slug
WHERE m.uf IS NULL OR m.nome IS NULL
GROUP BY r.uf, r.municipio;
--   uf  |          municipio          | total
-- ------+-----------------------------+-------
--  AC   | MARINGA                     |     1
--  AL   | ACRELANDIA                  |     2
--  AL   | BRASILEIA                   |     1
--  AL   | MAMANGUAPE                  |     1
--  AL   | OLINDA                      |     1
--  AM   | BELO HORIZONTE              |     1
--  AM   | BRASILEIA                   |     1
--  AM   | GUAJARA-MIRIM               |     1
--  AM   | OLINDA                      |     1
--  AM   | SAO PAULO                   |     2
--  AP   | CAMBE                       |     1
--  AP   | SAO PAULO                   |     1
--  BA   | AMERICANA                   |     1
--  BA   | ARACAJU                     |     1
--  BA   | BENEVIDES                   |     2
--  BA   | BRASILEIA                   |     2
--  BA   | CAPIVARI                    |     2
--  BA   | EXTERIOR                    |     1
--  BA   | FORTALEZA                   |     1
--  BA   | JAU                         |     1
--  BA   | LAGEDO DO TABOCAL           |    51
--  BA   | LAJEADO GRANDE              |     2
--  BA   | MUQUEM DO SAO FRANCISCO     |   117
--  BA   | NAVIRAI                     |     1
--  BA   | PETROLINA                   |     5
--  BA   | PIRACICABA                  |     3
--  BA   | PORTAO                      |     1
--  BA   | RIO DE JANEIRO              |     5
--  BA   | SANTOS                      |     1
--  BA   | SINOP                       |     2
--  CE   | APARECIDA DE GOIANIA        |     1
--  CE   | BRASILEIA                   |     1
--  CE   | FORTALEZA DO TABOCAO        |     1
--  CE   | RECIFE                      |     3
--  DF   | ALTA FLORESTA D'OESTE       |     1
--  DF   | BRASILEIA                   |     2
--  DF   | BRASILIA DE MINAS           |     1
--  DF   | FLORIANOPOLIS               |     1
--  DF   | GOIANIA                     |     2
--  DF   | LAGOA DOS PATOS             |     1
--  DF   | MANGUEIRINHA                |     1
--  DF   | RIO DE JANEIRO              |     7
--  DF   | SAO PAULO                   |     1
--  DF   | VALPARAISO                  |     1
--  ES   | ABREU E LIMA                |     1
--  ES   | ALTA FLORESTA D'OESTE       |     2
--  ES   | EXTREMOZ                    |     1
--  ES   | IGUABA GRANDE               |    11
--  ES   | RIO DE JANEIRO              |     3
--  ES   | SANTA ROSA                  |     1
--  ES   | SANTO ANDRE                 |     2
--  ES   | SAO PAULO                   |     1
--  ES   | VITORIA DO XINGU            |     3
--  ES   | VOLTA GRANDE                |     6
--  GO   | ABADIA DOS DOURADOS         |     7
--  GO   | ABELARDO LUZ                |     1
--  GO   | ALTA FLORESTA D'OESTE       |     9
--  GO   | ARAPORA                     |     1
--  GO   | BRASILEIA                   |     2
--  GO   | BRASILIA                    |    20
--  GO   | GLORINHA                    |     1
--  GO   | GOIANA                      |     7
--  GO   | GOIANESIA DO PARA           |     1
--  GO   | GURUPI                      |     2
--  GO   | JARU                        |     5
--  GO   | LAURO DE FREITAS            |     1
--  GO   | MIRASSOL D'OESTE            |     2
--  GO   | RIO BRANCO                  |     1
--  GO   | SAO LUIS                    |     1
--  GO   | SAO PAULO                   |     3
--  GO   | TUPASSI                     |     1
--  GO   | VALPARAISO                  |     1
--  GO   | VARGEM                      |     1
--  MA   | ARIQUEMES                   |     1
--  MA   | SAO LUIS DO QUITUNDE        |     1
--  MA   | SAO LUIZ                    |     1
--  MG   | ABADIA DE GOIAS             |    27
--  MG   | AGUAS DA PRATA              |     1
--  MG   | AMERICANA                   |     3
--  MG   | AMPARO DO SERRA             |    95
--  MG   | BARRA DO BUGRES             |     6
--  MG   | BARRETOS                    |     1
--  MG   | BRASILEIA                   |    12
--  MG   | BRAZOPOLIS                  |   371
--  MG   | BREJO GRANDE DO ARAGUAIA    |     1
--  MG   | CAMPINAS                    |     2
--  MG   | CATALAO                     |     1
--  MG   | DIAMANTINO                  |     1
--  MG   | EXTERIOR                    |     1
--  MG   | GUARULHOS                   |     1
--  MG   | ITAPORA                     |     4
--  MG   | MARITUBA                    |     7
--  MG   | RIO DE JANEIRO              |     1
--  MG   | SANTANA DE PARNAIBA         |     1
--  MG   | SAO LUIS                    |     1
--  MG   | SAO MATEUS                  |     1
--  MG   | SAO PAULO                   |     3
--  MG   | SAO THOME DAS LETRAS        |   158
--  MG   | SERRA                       |     1
--  MG   | TIETE                       |     1
--  MG   | UMUARAMA                    |     1
--  MG   | VOTUPORANGA                 |     2
--  MS   | ABADIA DE GOIAS             |     2
--  MS   | ARACATUBA                   |     2
--  MS   | CUIABA                      |     1
--  MS   | EXTERIOR                    |     2
--  MS   | NULL                        |     1
--  MS   | PRIMAVERA DO LESTE          |     1
--  MS   | SAO PAULO                   |     1
--  MS   | UMUARAMA                    |     4
--  MT   | ACRELANDIA                  |     1
--  MT   | CURITIBA                    |     1
--  MT   | DOM PEDRITO                 |     2
--  MT   | FIRMINOPOLIS                |     1
--  MT   | MATO GROSSO                 |     2
--  MT   | PALMEIRAS DE GOIAS          |     1
--  MT   | VARZEA BRANCA               |     1
--  NULL | NULL                        |    12
--  PA   | ALTA FLORESTA D'OESTE       |    32
--  PA   | ARACAJU                     |     4
--  PA   | BRASILEIA                   |     2
--  PA   | ELDORADO DO CARAJAS         |   168
--  PA   | JABOATAO DOS GUARARAPES     |     1
--  PA   | LUCAS DO RIO VERDE          |     3
--  PA   | OSASCO                      |     1
--  PA   | SANTA IZABEL DO PARA        |   852
--  PA   | TAQUARA                     |     1
--  PE   | ABADIA DE GOIAS             |     1
--  PE   | BARUERI                     |     1
--  PE   | BELEM DO SAO FRANCISCO      |   194
--  PE   | BOA VIAGEM                  |     2
--  PE   | IGUARACY                    |    54
--  PE   | LAGOA DE ITAENGA            |   193
--  PE   | NOVA BRASILANDIA D'OESTE    |     2
--  PE   | NOVA OLINDA DO NORTE        |     1
--  PE   | RIO CLARO                   |     3
--  PE   | SALVADOR                    |     2
--  PE   | SAO PAULO                   |     2
--  PE   | SERRA                       |     1
--  PR   | ACRELANDIA                  |    10
--  PR   | AMERICANA                   |     1
--  PR   | BLUMENAU                    |     1
--  PR   | BRASILEIA                   |     5
--  PR   | CAMPO GRANDE                |     1
--  PR   | CEREJEIRAS                  |     2
--  PR   | CHAPECO                     |     1
--  PR   | CORONEL SAPUCAIA            |     6
--  PR   | EXTREMA                     |     1
--  PR   | FORMOSA DO RIO PRETO        |     2
--  PR   | FRANCISCO SANTOS            |     3
--  PR   | GOIANIA                     |     1
--  PR   | GUARULHOS                   |     1
--  PR   | IPIRANGA DO PIAUI           |     2
--  PR   | ITAPORANGA                  |     1
--  PR   | IVINHEMA                    |     1
--  PR   | JANDAIA                     |     8
--  PR   | JOACABA                     |     1
--  PR   | JUNDIAI                     |     1
--  PR   | LAJEADO GRANDE              |     1
--  PR   | MACEIO                      |     2
--  PR   | MATHIAS LOBATO              |     1
--  PR   | MONSENHOR TABOSA            |     1
--  PR   | MUNHOZ DE MELLO             |    87
--  PR   | NOVO ORIENTE DO PIAUI       |     7
--  PR   | PARNAGUA                    |     2
--  PR   | PELOTAS                     |     1
--  PR   | PIRIPIRI                    |     4
--  PR   | SANTA CRUZ DO RIO PARDO     |     1
--  PR   | SAO PAULO                   |     5
--  PR   | SERRA                       |     2
--  PR   | URUANA DE MINAS             |     1
--  PR   | VALINHOS                    |     1
--  PR   | XAMBIOA                     |     2
--  RJ   | ALTA FLORESTA D'OESTE       |     2
--  RJ   | AMERICANA                   |     3
--  RJ   | ARARAQUARA                  |     1
--  RJ   | BARUERI                     |     1
--  RJ   | BELO HORIZONTE              |     1
--  RJ   | BRASILEIA                   |    16
--  RJ   | BRASILIA                    |     5
--  RJ   | CARAPICUIBA                 |     1
--  RJ   | CERQUEIRA CESAR             |     1
--  RJ   | COARACI                     |     2
--  RJ   | ESCADA                      |     2
--  RJ   | GRUPIARA                    |     2
--  RJ   | PERUIBE                     |     1
--  RJ   | PORTO ALEGRE                |     2
--  RJ   | RIO ACIMA                   |     1
--  RJ   | RIO DAS PEDRAS              |     1
--  RJ   | SALVADOR                    |     2
--  RJ   | SAO GONCALO DO AMARANTE     |     1
--  RJ   | SAO JOSE DOS PINHAIS        |     1
--  RJ   | SAO PAULO                   |    13
--  RJ   | SERRA                       |     2
--  RJ   | TAGUATINGA                  |     1
--  RJ   | URUTAI                      |     9
--  RJ   | VITORIA                     |     2
--  RN   | ABADIA DE GOIAS             |     2
--  RN   | BATATAIS                    |     1
--  RN   | CACHOEIRA DO SUL            |     1
--  RN   | IGREJINHA                   |     1
--  RO   | ACRELANDIA                  |     1
--  RO   | ALTA FLORESTA               |     1
--  RO   | BELEM                       |     1
--  RR   | MANAUS                      |     1
--  RS   | ACRELANDIA                  |     3
--  RS   | ARARANGUA                   |     1
--  RS   | BOA VISTA                   |     1
--  RS   | BRASILEIA                   |     3
--  RS   | CHAPECO                     |     1
--  RS   | CURITIBA                    |     3
--  RS   | GUARAPUAVA                  |     1
--  RS   | MARECHAL THAUMATURGO        |     1
--  RS   | NULL                        |   126
--  RS   | OSASCO                      |     1
--  RS   | PARAISO DO TOCANTINS        |     1
--  RS   | PLANALTO ALEGRE             |     9
--  RS   | PONTA PORA                  |     1
--  RS   | PORTALEGRE                  |     1
--  RS   | SALVADOR                    |     1
--  RS   | SANT'ANA DO LIVRAMENTO      |  3412
--  RS   | SAO JOSE DOS PINHAIS        |     1
--  RS   | SAPUCAIA                    |     2
--  RS   | WENCESLAU BRAZ              |     2
--  SC   | ACRELANDIA                  |     1
--  SC   | ARAPOEMA                    |     2
--  SC   | BALIZA                      |    89
--  SC   | BALNEARIO PICARRAS          |  1169
--  SC   | BARRACAO                    |     3
--  SC   | BARUERI                     |     2
--  SC   | BOM JARDIM                  |     1
--  SC   | BRASILEIA                   |     1
--  SC   | CURITIBA                    |     2
--  SC   | ENTRE IJUIS                 |     1
--  SC   | FEIRA DE SANTANA            |     2
--  SC   | FLORESTOPOLIS               |     2
--  SC   | FLORIANO                    |     4
--  SC   | FLORIDA                     |     1
--  SC   | GUARULHOS                   |     2
--  SC   | GURUPI                      |     9
--  SC   | IGREJINHA                   |     3
--  SC   | INDAIABIRA                  |     1
--  SC   | ITAJA                       |     1
--  SC   | LINHARES                    |     3
--  SC   | LUCIARA                     |     1
--  SC   | MACEIO                      |     1
--  SC   | MARACANAU                   |     1
--  SC   | NOSSA SENHORA DO LIVRAMENTO |    20
--  SC   | PAICANDU                    |     2
--  SC   | PALMAS                      |     6
--  SC   | PINHAIS                     |     1
--  SC   | PORTO ALEGRE                |     2
--  SC   | SAO JOSE DOS PINHAIS        |     1
--  SC   | SAO PAULO                   |     2
--  SC   | WENCESLAU BRAZ              |     2
--  SE   | ABADIA DE GOIAS             |     2
--  SE   | ARATUBA                     |     2
--  SE   | RECIFE                      |     2
--  SE   | SAO PAULO                   |     1
--  SP   | ABADIA DE GOIAS             |     1
--  SP   | ACAILANDIA                  |     2
--  SP   | ACRELANDIA                  |     2
--  SP   | AFONSO CUNHA                |     1
--  SP   | ALFENAS                     |     1
--  SP   | ALTAMIRA                    |     1
--  SP   | ALTAMIRA DO MARANHAO        |     2
--  SP   | ALTO BOA VISTA              |    15
--  SP   | ALTONIA                     |     1
--  SP   | ALVORADA D'OESTE            |     1
--  SP   | ARACITABA                   |     2
--  SP   | ARAIOSES                    |     3
--  SP   | ARAPIRACA                   |     1
--  SP   | ARAUA                       |     4
--  SP   | ARIQUEMES                   |     6
--  SP   | BARRA DO OURO               |     2
--  SP   | BLUMENAU                    |     1
--  SP   | BOA NOVA                    |     1
--  SP   | BODO                        |     1
--  SP   | BRACO DO NORTE              |     1
--  SP   | BRASILEIA                   |  8028
--  SP   | BRASILIA                    |     3
--  SP   | BRASIL NOVO                 |     2
--  SP   | BURITI DOS LOPES            |     4
--  SP   | CAMACAN                     |     8
--  SP   | CAMPO GRANDE                |     1
--  SP   | CANELA                      |     1
--  SP   | CARATINGA                   |     1
--  SP   | CASTANHEIRAS                |     2
--  SP   | CATALAO                     |     2
--  SP   | CHA GRANDE                  |     2
--  SP   | CHIAPETTA                   |     1
--  SP   | COCALZINHO DE GOIAS         |     2
--  SP   | CONDEUBA                    |     2
--  SP   | CRUZEIRO DO SUL             |     1
--  SP   | CURITIBA                    |     2
--  SP   | DARIO MEIRA                 |     2
--  SP   | ESPERANCA DO SUL            |    17
--  SP   | EUGENIO DE CASTRO           |     1
--  SP   | EUSEBIO                     |     1
--  SP   | EXTERIOR                    |     8
--  SP   | FERREIRA GOMES              |     2
--  SP   | FRAIBURGO                   |     6
--  SP   | GUAJARA-MIRIM               |    11
--  SP   | ICATU                       |     1
--  SP   | IGREJINHA                   |     1
--  SP   | IGUATU                      |     1
--  SP   | IPIXUNA                     |     3
--  SP   | JARDIM DE ANGICOS           |    10
--  SP   | JOAQUIM PIRES               |     1
--  SP   | JOINVILLE                   |     2
--  SP   | JOSE RAYDAN                 |     1
--  SP   | JURUTI                      |     1
--  SP   | MACAE                       |     1
--  SP   | MANAUS                      |     2
--  SP   | MATO LEITAO                 |     1
--  SP   | MAUA DA SERRA               |    29
--  SP   | MORADA NOVA DE MINAS        |     1
--  SP   | MOREIRA SALES               |     3
--  SP   | MUITOS CAPOES               |     1
--  SP   | NITEROI                     |     1
--  SP   | NOVA CANDELARIA             |    11
--  SP   | NOVA RAMADA                 |     1
--  SP   | OEIRAS DO PARA              |     1
--  SP   | PARELHAS                    |     2
--  SP   | PIMENTA BUENO               |     6
--  SP   | PORTO ALEGRE                |     1
--  SP   | PORTO SEGURO                |     2
--  SP   | PRIMAVERA                   |     1
--  SP   | QUERENCIA                   |     1
--  SP   | RECIFE                      |     1
--  SP   | RIACHAO                     |     1
--  SP   | RIO DE JANEIRO              |     7
--  SP   | RIO DO PRADO                |     2
--  SP   | RORAINOPOLIS                |     2
--  SP   | SAGRADA FAMILIA             |     1
--  SP   | SANTA IZABEL DO PARA        |     1
--  SP   | SANTA MARIA DO SUACUI       |     1
--  SP   | SANTO ANTONIO DA PATRULHA   |     2
--  SP   | SAO BERNARDO                |     1
--  SP   | SAO DESIDERIO               |     2
--  SP   | SAO DOMINGOS DAS DORES      |     1
--  SP   | SAO GERALDO DO ARAGUAIA     |     1
--  SP   | SAO JOAO DA LAGOA           |     1
--  SP   | SAO JOSE                    |     1
--  SP   | SAO JOSE DO BREJO DO CRUZ   |     1
--  SP   | SAO LOURENCO                |     1
--  SP   | SAO PATRICIO                |     1
--  SP   | SAO PAULO DAS MISSOES       |     1
--  SP   | SAO SEBASTIAO DO MARANHAO   |     1
--  SP   | SERRA                       |     4
--  SP   | SERRA DOS AIMORES           |     2
--  SP   | SILVEIRANIA                 |     1
--  SP   | SOBRADINHO                  |     2
--  SP   | TALISMA                     |     1
--  SP   | TANGUA                      |     1
--  SP   | VILA NOVA DO PIAUI          |     2
--  SP   | VIRGEM DA LAPA              |    12
--  SP   | VITORIA                     |     1
--  SP   | XAMBIOA                     |     2
--  SP   | ZABELE                      |     2
--  SP   | ZORTEA                      |    10
--  TO   | ABADIA DE GOIAS             |     1
--  TO   | ALTA FLORESTA D'OESTE       |     1
--  TO   | BRASILIA                    |     5
--  TO   | COUTO MAGALHAES             |    60
--  TO   | GOIANIA                     |     1
--  TO   | SAO LUIS                    |     1
--  TO   | TOCANTINS                   |     1


-- TODO: comparar tabela de municípios do IBGE com municipio_uf (usando slug)


-- Erro em estabelecimento: data com menos de 8 caracteres
SELECT
  cnpj_raiz,
  data_situacao_cadastral,
  data_situacao_especial,
  data_inicio_atividade
FROM estabelecimento_orig
WHERE
  (data_situacao_cadastral <> '0' AND data_situacao_cadastral IS NOT NULL AND LENGTH(data_situacao_cadastral) < 8)
  OR (data_situacao_especial <> '0' AND data_situacao_especial IS NOT NULL AND LENGTH(data_situacao_especial) < 8)
  OR (data_inicio_atividade <> '0' AND data_inicio_atividade IS NOT NULL AND LENGTH(data_inicio_atividade) < 8)
;
--  cnpj_raiz | data_situacao_cadastral | data_situacao_especial | data_inicio_atividade
-- -----------+-------------------------+------------------------+-----------------------
--  49009023  | 2021221                 |                        | 2021221


-- Erro em socio: nome do sócio em branco
SELECT COUNT(*) FROM socio_orig WHERE COALESCE(nome, '') = '';
--  count
-- -------
--   2087

-- Erro em socio: CPF/CNPJ sócio em branco
SELECT COUNT(*) FROM socio_orig WHERE COALESCE(cpf_cnpj, '') = '';
--  count
-- -------
--  12928
-- Detalhe: alguns dos sócios que não possuem `cpf_cnpj` preenchidos são empresas e existem empresas cujas razões
-- sociais são iguais, por exemplo:
SELECT * FROM socio WHERE nome = '1699516 ONTARIO INC';
-- socio_uuid                        |
-- empresa_uuid                      | 612d72ff-910a-5a6a-930e-5c811a8f0a9f
-- cnpj_raiz                         | 07999552
-- codigo_identificador              | 3
-- nome                              | 1699516 ONTARIO INC
-- cpf_cnpj                          |
-- codigo_qualificacao               | 37
-- data_entrada_sociedade            | 2006-07-03
-- codigo_pais                       | 149
-- representante_cpf_cnpj            | ***554628**
-- representante                     | CINTIA VANNUCCI VAZ GUIMARAES
-- representante_codigo_qualificacao | 17
-- representante_uuid                | 6418151e-afd6-50cf-aa13-b7e58886c9a2
-- codigo_faixa_etaria               |
SELECT * FROM empresa WHERE razao_social = '1699516 ONTARIO INC';
-- uuid                              | 7886b1c2-d9a7-5b13-bc7a-4a1d35ca05dc
-- pessoa_uuid                       |
-- codigo_natureza_juridica          | 2216
-- codigo_qualificacao_responsavel   | 17
-- codigo_porte                      | 5
-- ente_responsavel_codigo_municipio |
-- capital_social                    | 0.00
-- cnpj_raiz                         | 08157912
-- razao_social                      | 1699516 ONTARIO INC
-- ente_responsavel_uf               |


-- TODO: existe um caso na base limpa em que `nome` e `cpf_cnpj` são nulos conjuntamente, mas não na base original.
-- Precisamos investigar e criar o check.
SELECT COUNT(*) FROM socio WHERE COALESCE(nome, '') = '' AND COALESCE(cpf_cnpj, '') = '';
--  count
-- -------
--      1
SELECT COUNT(*) FROM socio_orig WHERE COALESCE(nome, '') = '' AND COALESCE(cpf_cnpj, '') = '';
--  count
-- -------
--      0

-- A maior parte dos casos de sócios com nome ou CPF/CNPJ em branco são do exterior, mas existem outros casos também:
SELECT
  s.codigo_qualificacao,
  q.descricao,
  COUNT(s.*)
FROM socio_orig AS s
LEFT JOIN qualificacao_socio AS q
  ON s.codigo_qualificacao = q.codigo
WHERE COALESCE(cpf_cnpj, '') = '' OR COALESCE(nome, '') = ''
GROUP BY 1, 2
ORDER BY 3 DESC;
--  codigo_qualificacao |                             descricao                             | count
-- ---------------------+-------------------------------------------------------------------+-------
--                   37 | Sócio Pessoa Jurídica Domiciliado no Exterior                     |  9033
--                   38 | Sócio Pessoa Física Residente no Exterior                         |  2587
--                   16 | Presidente                                                        |  2034
--                   72 | Diretor Residente ou Domiciliado no Exterior                      |   577
--                   70 | Administrador Residente ou Domiciliado no Exterior                |   265
--                   71 | Conselheiro de Administração Residente ou Domiciliado no Exterior |   189
--                   74 | Sócio-Administrador Residente ou Domiciliado no Exterior          |   128
--                   73 | Presidente Residente ou Domiciliado no Exterior                   |   106
--                   22 | Sócio                                                             |    28
--                   49 | Sócio-Administrador                                               |    28
--                   75 | Fundador Residente ou Domiciliado no Exterior                     |    25
--                   17 | Procurador                                                        |    10
--                   10 | Diretor                                                           |     3
--                   33 | Tesoureiro                                                        |     1
--                    5 | Administrador                                                     |     1


-- Possível erro em socio: cpf_cnpj = '***000000**' (deveria ser em branco ou é só coincidência?)
SELECT COUNT(*) FROM socio_orig wHERE cpf_cnpj = '***000000**';
--  count
-- -------
--   1123
