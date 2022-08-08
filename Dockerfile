ARG         version=
ARG         base=redis:${version}-alpine

###

FROM        ${base} as rejson

ARG         rejson_version=2.2.0

WORKDIR     /

RUN         apk add --no-cache --virtual .build-deps \
                build-base \
                rust \
                cargo \
                clang-libs && \
            wget -O - https://github.com/RedisJSON/RedisJSON/archive/refs/tags/v${rejson_version}.tar.gz | tar xz && \
            cd RedisJSON-${rejson_version} && \
            cargo build --release && \
            install -D -o redis -g redis -t /usr/lib/redis/modules target/release/librejson.so && \
            apk del .build-deps

###

FROM        ${base}

CMD         ["redis-server", "--loadmodule", "/usr/lib/redis/modules/rejson.so"]

RUN         apk add --virtual .run-deps \
                libgcc

COPY        --from=rejson --chown=redis:redis /usr/lib/redis/modules/librejson.so /usr/lib/redis/modules/rejson.so
