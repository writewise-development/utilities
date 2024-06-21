FROM node:20-slim AS devbase
ARG PORT
EXPOSE ${PORT}

FROM devbase AS debian-cert
ARG DEVCERT_CRT
USER root
COPY ${DEVCERT_CRT} /usr/local/share/ca-certificates/localhost.crt
RUN chmod 644 /usr/local/share/ca-certificates/localhost.crt \
    && apt-get update \
    && apt-get install ca-certificates -y \
    && apt-get clean \
    && update-ca-certificates

FROM debian-cert AS install-tools
RUN apt-get update \
    && apt-get install net-tools -y \
    && apt-get clean

FROM install-tools AS health-check
ARG PORT
ENV PORT=${PORT}
HEALTHCHECK --interval=5s --retries=20 --start-period=5s --timeout=10s CMD netstat -ltn | grep -c ${PORT}

FROM health-check AS dev
WORKDIR /src
ENTRYPOINT ["sh", "-c", "chown -R node:node /src/node_modules && su node -c 'yarn install --inline-builds && yarn dev'"]
