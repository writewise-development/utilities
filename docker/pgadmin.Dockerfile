FROM dpage/pgadmin4:8.6 AS base

FROM base AS copy-cert
ARG DEVCERT_CRT
USER root
COPY ${DEVCERT_CRT} /usr/local/share/ca-certificates/localhost.crt

FROM copy-cert AS alpine-cert
ARG DEVCERT_CRT
USER root
COPY ${DEVCERT_CRT} /usr/local/share/ca-certificates/localhost.crt
RUN chmod 644 /usr/local/share/ca-certificates/localhost.crt \
    && apk update \
    && apk add ca-certificates \
    && apk cache clean \
    && update-ca-certificates

FROM alpine-cert AS pgadminhttps
ARG DEVCERT_CRT
ARG DEVCERT_KEY    
COPY ${DEVCERT_CRT} /certs/server.cert
COPY ${DEVCERT_KEY} /certs/server.key

FROM pgadminhttps AS dev
ARG DB_NAME
ARG PORT_DB
ARG POSTGRES_DB
ARG POSTGRES_USER
ENV PGADMIN_SERVER_JSON_FILE=/host-files/${DB_NAME}.json
RUN mkdir -p /host-files && printf "{\n\
    \"Servers\": {\n\
    \"1\": {\n\
    \"Group\": \"Servers\",\n\
    \"Host\": \"localhost\",\n\
    \"MaintenanceDB\": \"postgres\",\n\
    \"Name\": \"${DB_NAME}\",\n\
    \"Port\": ${PORT_DB},\n\
    \"SSLCompression\": 0,\n\
    \"SSLMode\": \"require\",\n\
    \"Timeout\": 10,\n\
    \"TunnelAuthentication\": 0,\n\
    \"Username\": \"${POSTGRES_USER}\",\n\
    \"UseSSHTunnel\": 0\n\
    }\n\
    }\n\
    }\n" > /host-files/${DB_NAME}.json
