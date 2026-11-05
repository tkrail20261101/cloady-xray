# syntax=docker/dockerfile:1
# cloady-xray: xray (VLESS + WebSocket + TLS) for the Cloady free plan.
# TLS is terminated at the Cloady edge; xray itself serves plain WebSocket
# on the container port (default 3000).
ARG XRAY_VERSION=26.10.31

# Stage 1: fetch the xray release archive and unpack it.
FROM alpine:3.20 AS fetch
ARG XRAY_VERSION
RUN apk add --no-cache curl unzip \
    && curl -fsSL -o /tmp/xray.zip \
        "https://github.com/XTLS/Xray-core/releases/download/v${XRAY_VERSION}/Xray-linux-64.zip" \
    && unzip -q /tmp/xray.zip -d /tmp/xray

# Stage 2: minimal runtime image - only the xray binary on Alpine.
FROM alpine:3.20
RUN apk add --no-cache ca-certificates
COPY --from=fetch /tmp/xray/xray /usr/local/bin/xray
COPY config.json /etc/xray/config.json
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh /usr/local/bin/xray
EXPOSE 3000
ENTRYPOINT ["/entrypoint.sh"]
