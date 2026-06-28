#!/bin/sh

CONFIGS_DEFAULT="$(cat .config.default)"
CONFIGS_USER=$(cat .config)
while read LINE; do
    CONFIG_NAME=$(echo "$LINE" | awk -F '=' '{print $1}')
    CONFIG_VALUE=$(echo "$LINE" | awk -F '=' '{print $2}')
    CONFIG_MATCH=$(echo "$CONFIGS_USER" | grep -E "^$CONFIG_NAME=")
    CONFIG_MATCH_VALUE=$(echo "$CONFIG_MATCH" | awk -F '=' '{print $2}')
    [ "$CONFIG_VALUE" = "$CONFIG_MATCH_VALUE" ] || echo "$CONFIG_NAME: $CONFIG_VALUE -> $CONFIG_MATCH_VALUE"
done <<-EOF
$(echo "$CONFIGS_DEFAULT" | grep -E '^[A-Z].*')
EOF