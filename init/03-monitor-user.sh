#!/bin/bash
# Crea el usuario "monitor" para postgres_exporter (Prometheus): solo lee estadisticas.
# El rol pg_monitor no da acceso a los datos de las tablas.
# La contraseña viene de MONITOR_DB_PASSWORD (.env). Si falta, se omite (la BD funciona igual).
# Sin "exit": el entrypoint de postgres puede ejecutar este archivo con "source".
set -euo pipefail

if [ -z "${MONITOR_DB_PASSWORD:-}" ]; then
    echo "MONITOR_DB_PASSWORD vacia: no se crea el usuario monitor."
else
    psql -v ON_ERROR_STOP=1 -v mon_pwd="$MONITOR_DB_PASSWORD" --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<'EOSQL'
CREATE ROLE monitor LOGIN PASSWORD :'mon_pwd'
    NOSUPERUSER NOCREATEDB NOCREATEROLE;
GRANT pg_monitor TO monitor;

DO $$
BEGIN
    EXECUTE format('GRANT CONNECT ON DATABASE %I TO monitor', current_database());
END $$;
EOSQL
fi
