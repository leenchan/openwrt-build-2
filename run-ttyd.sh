#!/bin/sh
CUR_DIR=$(cd $(dirname $0); pwd)

. $CUR_DIR/functions.sh

[ -x "$(which ttyd)" ] || {
	echo "Installing ttyd..."
	TTYD_DL_URL=$(get_github_release "tsl0922/ttyd" "1.7.4" "x86_64")
	install_bin "${TTYD_DL_URL}" "$(basename "$TTYD_DL_URL"):ttyd"
}

[ -x "$(which ngrok)" ] || {
	echo "Installing ngrok..."
	# NGROK_DL_URL=$(get_urls_from_html "https://ngrok.com/downloads/linux?tab=download" | grep 'amd64' | head -n1)
	NGROK_DL_URL="https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.tgz"
	install_bin "$NGROK_DL_URL" "ngrok"
}

[ -x "$(which ttyd)" -a -x "$(which ngrok)" ] || exit 1

[ -z "${NGROK_AUTHTOKEN}" ] && {
	echo "Please set secrets.NGROK_AUTHTOKEN in repo settings"
	exit 1
}

[ -z "${1}" ] && {
	echo "Please provide a command to run"
	exit 1
}

ttyd -W -p 7681 sh -c "${1}; killall ngrok" &
(sleep ${2:-3600} && killall ngrok) &
ngrok http 7681 --authtoken $NGROK_AUTHTOKEN --log=stdout 2>&1 || exit 0 && exit 0

exit 0
