FROM buildpack-deps:bullseye AS builder

# from https://github.com/wilzbach/dlang-docker/blob/master/ubuntu/dlang.docker
RUN apt-get update \
    && apt-get install -y \
    ca-certificates \
    curl \
    libc6-dev \
    gcc \
    libssl-dev \
    libxml2 \
    libz-dev \
    make \
    xz-utils \
    && update-alternatives --install "/usr/bin/ld" "ld" "/usr/bin/ld.gold" 20 \
	&& update-alternatives --install "/usr/bin/ld" "ld" "/usr/bin/ld.bfd" 10

RUN groupadd --gid 1001 dlang \
  && useradd --uid 1001 --gid dlang --shell /bin/bash --create-home dlang

RUN mkdir /dlang && chown dlang /dlang

USER dlang

RUN set -ex && \
	curl -fsS https://dlang.org/install.sh | bash -s ldc-1.28.1 -p /dlang

USER root

RUN chmod 755 -R /dlang

ENV PATH="/dlang/ldc-1.28.1/bin:${PATH:-}"
ENV LIBRARY_PATH="/dlang/ldc-1.28.1/lib${LIBRARY_PATH:+:}:${LIBRARY_PATH:-}"
ENV LD_LIBRARY_PATH="/dlang/ldc-1.28.1/lib${LD_LIBRARY_PATH:+:}:${LD_LIBRARY_PATH:-}"

WORKDIR /app
COPY . /app
RUN dub build -b release

FROM buildpack-deps:bullseye

RUN apt-get update && apt-get install -y netcat unzip imagemagick libssl-dev

COPY --from=builder /app/dub-registry /opt/dub-registry/dub-registry
COPY public /opt/dub-registry/public
COPY categories.json /opt/dub-registry/categories.json
COPY docker-entrypoint.sh /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]
