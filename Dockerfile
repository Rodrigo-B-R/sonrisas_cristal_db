FROM postgres:17

# Scripts .sql/.sh en esta carpeta se ejecutan UNA sola vez, cuando el volumen
# de datos esta vacio (primera inicializacion).
COPY init/ /docker-entrypoint-initdb.d/

EXPOSE 5432
