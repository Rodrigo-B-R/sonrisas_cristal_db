#!/bin/bash
# Crea el usuario de la API: solo SELECT, INSERT y UPDATE; no puede alterar el esquema.
# La contraseña viene de API_DB_PASSWORD (.env); no se escribe en el repositorio.
# Corre despues de 01-init.sql, asi que las tablas ya existen.
set -euo pipefail

: "${API_DB_PASSWORD:?Falta API_DB_PASSWORD en .env}"

psql -v ON_ERROR_STOP=1 -v api_pwd="$API_DB_PASSWORD" --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<'EOSQL'
CREATE ROLE api_user LOGIN PASSWORD :'api_pwd'
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

-- Auditoria append-only: la API solo la lee. Las filas las escribe el trigger
-- (SECURITY DEFINER), asi nadie puede insertar ni alterar registros de auditoria.
REVOKE INSERT, UPDATE ON auditoria FROM api_user;

-- Tablas y secuencias futuras creadas por el dueño (postgres)
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT, INSERT, UPDATE ON TABLES TO api_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT USAGE, SELECT ON SEQUENCES TO api_user;
EOSQL
