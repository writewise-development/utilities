FROM mcr.microsoft.com/dotnet/sdk:8.0 AS devbase
WORKDIR /app
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

FROM debian-cert AS visualstudio
USER app

FROM debian-cert AS install-tools
RUN apt-get update \
    && apt-get install net-tools -y \
    && apt-get clean

FROM install-tools AS health-check
ARG PORT
ENV PORT=${PORT}
HEALTHCHECK --interval=10s --retries=16 --start-period=60s --timeout=5s CMD netstat -ltn | grep -c ${PORT}

FROM health-check AS add-user
ARG GID
ARG PORT
ARG UID
ARG USER
RUN groupadd --gid ${GID} ${USER} && useradd -l --uid ${UID} --gid ${GID} --create-home ${USER}

FROM add-user AS dev
ARG PROJECT
ENV PROJECT=${PROJECT}
WORKDIR /src
USER ${USER}
ENTRYPOINT dotnet watch --no-launch-profile --project "${PROJECT}/${PROJECT}.csproj" -v
