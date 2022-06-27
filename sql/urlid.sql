CREATE EXTENSION IF NOT EXISTS "unaccent";
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE OR REPLACE FUNCTION slug(value TEXT)
RETURNS TEXT AS $$
BEGIN
  RETURN REGEXP_REPLACE(
    REGEXP_REPLACE(
      REGEXP_REPLACE(
        lower(unaccent(value)),
        '[^a-z0-9_-]+', '-', 'gi'
      ),
      '^-', ''
    ),
    '-$', ''
  );
END; $$ LANGUAGE 'plpgsql' IMMUTABLE;

CREATE OR REPLACE FUNCTION company_internal_id(cnpj TEXT)
RETURNS TEXT AS $$
BEGIN
  RETURN LEFT(cnpj, 8);
END; $$ LANGUAGE 'plpgsql' IMMUTABLE;

CREATE OR REPLACE FUNCTION person_internal_id(cpf TEXT, nome TEXT)
RETURNS TEXT AS $$
BEGIN
  RETURN RIGHT(LEFT(cpf, 9), 6) || '-' || UPPER(slug(nome));
END; $$ LANGUAGE 'plpgsql' IMMUTABLE;

CREATE OR REPLACE FUNCTION person_uuid(cpf TEXT, nome TEXT)
RETURNS UUID AS $$
BEGIN
  RETURN uuid_generate_v5(uuid_ns_url(), 'https://id.brasil.io/person/v1/' || person_internal_id(cpf, nome) || '/');
END; $$ LANGUAGE 'plpgsql' IMMUTABLE;

CREATE OR REPLACE FUNCTION company_internal_id(cnpj TEXT)
RETURNS TEXT AS $$
BEGIN
  RETURN LEFT(cnpj, 8);
END; $$ LANGUAGE 'plpgsql' IMMUTABLE;

CREATE OR REPLACE FUNCTION company_uuid(cnpj TEXT)
RETURNS UUID AS $$
BEGIN
  RETURN uuid_generate_v5(uuid_ns_url(), 'https://id.brasil.io/company/v1/' || company_internal_id(cnpj) || '/');
END; $$ LANGUAGE 'plpgsql' IMMUTABLE;

CREATE OR REPLACE FUNCTION candidacy_uuid(ano smallint, numero_sequencial text)
RETURNS UUID AS $$
BEGIN
  RETURN uuid_generate_v5(uuid_ns_url(), 'https://id.brasil.io/candidacy/v1/' || ano::text || '-' || regexp_replace(numero_sequencial, '[^0-9]', '', 'g') || '/');
END; $$ LANGUAGE 'plpgsql' IMMUTABLE;
