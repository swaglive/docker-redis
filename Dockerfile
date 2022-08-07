FROM        alpine:3.15 AS rejson

ARG         REDIS_JSON_VERSION=2.2.0
WORKDIR     /usr/lib/
RUN         apk add --no-cache --virtual .build-deps \
                curl \
                rust \
                cargo \
                clang-libs \
                build-base
RUN         curl -sfLO https://github.com/RedisJSON/RedisJSON/archive/refs/tags/v${REDIS_JSON_VERSION}.tar.gz && \
            tar -xvzf v${REDIS_JSON_VERSION}.tar.gz && \
            mv RedisJSON-${REDIS_JSON_VERSION} RedisJSON &&\
            cd  RedisJSON && \
            cargo build --release  && \
            apk del .build-deps


FROM        redis:7.0-alpine
RUN         apk add build-base
RUN         mkdir -p "/usr/lib/redis/modules"
COPY        --from=rejson    /usr/lib/RedisJSON/target/release/librejson.so   "/usr/lib/redis/modules/rejson.so"
RUN         chown -R redis:redis /usr/lib/redis/modules

