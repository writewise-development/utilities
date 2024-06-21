FROM node:20-slim AS node-base
ARG SPA_FOLDER
ENV NODE_ENV=production
RUN corepack enable
WORKDIR /app
COPY src/${SPA_FOLDER}/package.json src/${SPA_FOLDER}/yarn.lock src/${SPA_FOLDER}/.yarnrc.yml ./
RUN yarn install --immutable --inline-builds

FROM node-base AS vue-build
WORKDIR /app
COPY --from=node-base /app/node_modules /app/node_modules
COPY src/${SPA_FOLDER} .
RUN yarn build

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS restore
ARG PROJECT
ENV PATH="${PATH}:/root/.dotnet/tools"
RUN dotnet tool install --global --no-cache dotnet-subset --version 0.3.2
WORKDIR /src
COPY src .
RUN dotnet subset restore "${PROJECT}/${PROJECT}.csproj" --root-directory /src --output /restore_subset    

FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
ARG PORT
USER app
WORKDIR /app
EXPOSE ${PORT}

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS copy-dist
ARG PROJECT
WORKDIR /src
COPY --from=node-base-build /app/dist ${PROJECT}/wwwroot

FROM copy-dist AS build
ARG BUILD=Release
ARG PROJECT
WORKDIR /src
COPY --from=restore /restore_subset .
RUN dotnet restore "${PROJECT}/${PROJECT}.csproj"
COPY src .
RUN dotnet build "${PROJECT}/${PROJECT}.csproj" -c ${BUILD} --no-restore -o /app/build

FROM build AS publish
ARG BUILD=Release
RUN dotnet publish "${PROJECT}/${PROJECT}.csproj" -c ${BUILD} -o /app/publish /p:UseAppHost=false

FROM base AS container
WORKDIR /app/publish
COPY --from=publish /app/publish /app/publish/
ENTRYPOINT dotnet /app/publish/${PROJECT}.dll
