# syntax=docker/dockerfile:1


FROM buildpack-deps:bookworm AS build

RUN set -eux; \
    wget -O ldc.tar.xz https://github.com/ldc-developers/ldc/releases/download/v1.40.1/ldc2-1.40.1-linux-x86_64.tar.xz; \
    tar --strip-components=1 -C /usr/local -Jxf ldc.tar.xz; \
    rm ldc.tar.xz
WORKDIR /app
COPY . .
RUN dub build

# Based on https://github.com/rracariu/docker

FROM debian:bookworm-slim AS final

LABEL maintainer="DLang Community <community@dlang.io>"

EXPOSE 9095

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        netcat-traditional \
        unzip \
        imagemagick \
        libssl-dev; \
    rm -fr /var/lib/apt/lists/*

COPY public /opt/dub-registry/public
COPY categories.json /opt/dub-registry/categories.json
COPY docker-entrypoint.sh /entrypoint.sh
COPY --from=build /app/dub-registry /opt/dub-registry/dub-registry

ENTRYPOINT [ "/entrypoint.sh" ]
