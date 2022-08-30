CREATE EXTENSION IF NOT EXISTS "unaccent";
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE OR REPLACE FUNCTION slug(value TEXT)
RETURNS TEXT AS $$
BEGIN
  RETURN REGEXP_REPLACE(
    REGEXP_REPLACE(
      REGEXP_REPLACE(
        REGEXP_REPLACE(
          lower(unaccent(value)),
          '[^a-z0-9_-]+', '-', 'g'
        ),
        '-+', '-', 'g'
      ),
      '^-', ''
    ),
    '-$', ''
  );
END; $$ LANGUAGE 'plpgsql' IMMUTABLE;

CREATE OR REPLACE FUNCTION person_uuid(cpf TEXT, nome TEXT)
RETURNS UUID AS $$
BEGIN
  RETURN uuid_generate_v5(
    uuid_ns_url(),
    'https://id.brasil.io/person/v1/'
    || SUBSTR(RIGHT('00000000000' || REGEXP_REPLACE(cpf, '[^0-9*]+', '', 'g'), 11), 4, 6)
    || '-'
    || UPPER(slug(nome))
    || '/'
  );
END; $$ LANGUAGE 'plpgsql' IMMUTABLE;

CREATE OR REPLACE FUNCTION company_uuid(cnpj TEXT)
RETURNS UUID AS $$
BEGIN
  RETURN uuid_generate_v5(
    uuid_ns_url(),
    'https://id.brasil.io/company/v1/'
    || LEFT(RIGHT('00000000000000' || REGEXP_REPLACE(cnpj, '[^0-9*]+', '', 'g'), 14), 8)
    || '/'
  );
END; $$ LANGUAGE 'plpgsql' IMMUTABLE;

CREATE OR REPLACE FUNCTION company_branch_uuid(cnpj TEXT)
RETURNS UUID AS $$
BEGIN
  RETURN uuid_generate_v5(
    uuid_ns_url(),
    'https://id.brasil.io/company-branch/v1/'
    || RIGHT('00000000000000' || REGEXP_REPLACE(cnpj, '[^0-9*]+', '', 'g'), 14)
    || '/'
  );
END; $$ LANGUAGE 'plpgsql' IMMUTABLE;

CREATE OR REPLACE FUNCTION candidacy_uuid(ano SMALLINT, numero_sequencial TEXT)
RETURNS UUID AS $$
BEGIN
  RETURN uuid_generate_v5(
    uuid_ns_url(),
    'https://id.brasil.io/candidacy/v1/'
    || ano::text
    || '-'
    || REGEXP_REPLACE(numero_sequencial, '[^0-9]', '', 'g')
    || '/'
  );
END; $$ LANGUAGE 'plpgsql' IMMUTABLE;
