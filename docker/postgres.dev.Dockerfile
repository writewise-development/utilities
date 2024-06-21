FROM postgres:16 AS localbase

FROM localbase AS health-check
HEALTHCHECK --interval=5s --retries=5 --start-period=10s --timeout=10s CMD pg_isready

FROM health-check AS copy-cert
ARG DEVCERT_CRT
USER root
COPY ${DEVCERT_CRT} /usr/local/share/ca-certificates/localhost.crt

FROM health-check AS debian-cert
ARG DEVCERT_CRT
USER root
COPY ${DEVCERT_CRT} /usr/local/share/ca-certificates/localhost.crt
RUN chmod 644 /usr/local/share/ca-certificates/localhost.crt \
    && apt-get update \
    && apt-get install ca-certificates -y \
    && apt-get clean \
    && update-ca-certificates

FROM debian-cert AS postgreshttps
ARG DEVCERT_CRT
ARG DEVCERT_KEY    
COPY ${DEVCERT_CRT} /certs/localhost.crt
COPY ${DEVCERT_KEY} /certs/localhost.key
USER root
RUN chown postgres /certs/localhost.key
RUN chmod 600 /certs/localhost.key

FROM postgreshttps AS local
ARG DB_NAME
RUN printf "ALTER SYSTEM SET ssl_cert_file TO '/certs/localhost.crt';\n\
    ALTER SYSTEM SET ssl_key_file TO '/certs/localhost.key';\n\
    ALTER SYSTEM SET ssl TO 'ON';\n\
    CREATE DATABASE \"${DB_NAME}\";\n" \
    > /docker-entrypoint-initdb.d/${DB_NAME}config.sql
USER postgres
