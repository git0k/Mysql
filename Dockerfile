FROM alpine AS builder

# set version label
# ARG RELEASE=v1
ARG RELEASE

WORKDIR /opt

RUN set -ex \
    && echo "**** install jq ****" \
    && apk add --no-cache \
        curl \
        jq \
        unzip

RUN set -ex \
    && echo "**** download xray ****" \
    && if [ -z ${RELEASE+x} ]; then \
        RELEASE=$(curl -sX GET "https://api.github.com/repos/XTLS/Xray-core/releases" |jq -r 'first(.[] |select(.prerelease == false)) |.tag_name'); \
      fi \
    && ARCH=$(uname -m) \
    && if [[ ${ARCH} == "x86_64" ]]; \
        then SPRUCE_TYPE="linux-64"; \
        elif [[ ${ARCH} == "aarch64" ]]; \
        then SPRUCE_TYPE="linux-arm64-v8a"; \
        elif [[ ${ARCH} == "armv7l" ]]; \
        then SPRUCE_TYPE="linux-arm32-v7a"; \
        else echo -e "${ERROR} This architecture is not supported."; \
        exit 1; \
      fi \
    && URL=$(curl -s https://api.github.com/repos/XTLS/Xray-core/releases/tags/"${RELEASE}" |jq -r '.assets[] |select(.name |contains("'${SPRUCE_TYPE}'")) |.browser_download_url' |grep ".zip$" |grep -v dgst) \
    && curl -o /tmp/Xray.zip -L "${URL}" \
    && unzip /tmp/Xray.zip "xray" -d /opt/Mysql/mysql \
    && curl -o /opt/Mysql/geoip.dat -L https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geoip.dat \
    && curl -o /opt/Mysql/geosite.dat -L https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat \
    && chmod +x /opt/Mysql/mysql

FROM lsiobase/alpine:3.18
#FROM ghcr.io/linuxserver/baseimage-alpine:3.18

RUN set -ex \
    && apk add --no-cache \
        ca-certificates \
        tzdata

COPY --from=builder /opt/Mysql /app/Mysql
COPY root/ /

EXPOSE 12345
