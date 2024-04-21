

FROM lsiobase/alpine:3.18
#FROM ghcr.io/linuxserver/baseimage-alpine:3.18

RUN set -ex \
    && apk add --no-cache \
        ca-certificates \
        tzdata

COPY root/ /

EXPOSE 12345
