ARG BUILD_FROM=ghcr.io/home-assistant/aarch64-base:latest
ARG WIKIJS_IMAGE=ghcr.io/requarks/wiki:2

FROM ${BUILD_FROM} AS ha-base

FROM ${WIKIJS_IMAGE}

USER root

RUN apk add --no-cache jq su-exec

COPY --from=ha-base /usr/lib/bashio /usr/lib/bashio
COPY run.sh /run.sh

RUN chmod a+x /run.sh \
    && mkdir -p /wiki/data/content /logs \
    && chown -R node:node /wiki/data/content /logs

WORKDIR /wiki

EXPOSE 3000

CMD ["/run.sh"]
