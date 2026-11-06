-- Usuario de la API: solo SELECT, INSERT y UPDATE. No puede alterar el esquema.
-- Corre despues de 01-init.sql, asi que las tablas ya existen.

CREATE ROLE api_user LOGIN PASSWORD '~1Eg~4v6?=L7+km#mJVM!T~=A}DD*@jtqp%aRc#Y^e~TJ'
    NOSUPERUSER NOCREATEDB NOCREATEROLE NOINHERIT;

DO $$
BEGIN
    EXECUTE format('GRANT CONNECT ON DATABASE %I TO api_user', current_database());
END $$;

GRANT USAGE ON SCHEMA public TO api_user;
REVOKE CREATE ON SCHEMA public FROM api_user;

GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA public TO api_user;
-- Los id IDENTITY usan secuencias; sin esto falla el INSERT
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO api_user;

-- Tablas y secuencias futuras creadas por el dueño (postgres)
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT, INSERT, UPDATE ON TABLES TO api_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT USAGE, SELECT ON SEQUENCES TO api_user;
