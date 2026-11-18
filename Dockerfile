FROM postgres:17-alpine3.24

# Alpine (musl) ordena el texto por codigo Unicode: "Angela" con acento y "carmen" quedan despues de "Zoe".
# Con ICU es-MX el orden queda como en espanol (igual que la imagen Debian anterior).
# Solo se aplica al crear la BD (volumen vacio). Alpine fija (3.24) = version de ICU estable.
ENV POSTGRES_INITDB_ARGS="--locale-provider=icu --icu-locale=es-MX"

LABEL org.opencontainers.image.source="https://github.com/Rodrigo-B-R/sonrisas_cristal_db" \
      org.opencontainers.image.description="PostgreSQL 17 (Alpine) con el esquema de Sonrisas de Cristal"

# Scripts .sql/.sh en esta carpeta se ejecutan UNA sola vez, cuando el volumen
# de datos esta vacio (primera inicializacion).
COPY init/ /docker-entrypoint-initdb.d/

EXPOSE 5432
