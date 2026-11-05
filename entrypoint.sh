#!/bin/sh
# cloady-xray entrypoint: render config.json from env vars and run xray.
# Env vars (set in the Cloady dashboard; no secrets in this repo):
#   UUID     VLESS client UUID (required)
#   WS_PATH  WebSocket path, e.g. /ws-xxxx (default /vless)
#   PORT     container port xray listens on (default 3000)
set -eu

UUID="${UUID:-}"
WS_PATH="${WS_PATH:-/vless}"
PORT="${PORT:-3000}"

if [ -z "$UUID" ]; then
  echo "UUID env var is required" >&2
  exit 1
fi

# WS_PATH must start with a slash.
case "$WS_PATH" in
  /*) ;;
  *) WS_PATH="/$WS_PATH" ;;
esac

sed -e "s|__UUID__|${UUID}|g" \
    -e "s|__WS_PATH__|${WS_PATH}|g" \
    -e "s|__PORT__|${PORT}|g" \
    /etc/xray/config.json > /tmp/config.json

echo "Starting xray on port ${PORT}, ws path ${WS_PATH}"
exec /usr/local/bin/xray run -config /tmp/config.json
