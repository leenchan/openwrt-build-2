#!/bin/sh
CUR_DIR=$(cd $(dirname $0); pwd)

echo "GITHUB_ENV: $GITHUB_ENV"
echo "OPENWRT_ROOT_DIR: $OPENWRT_ROOT_DIR"

export OPENWRT_PACKAGES_DIR=

download_openwrt_package() {
	[ -z "$OPENWRT_PACKAGES_DIR" ] && {
		cd /tmp && git clone https://github.com/openwrt/packages.git openwrt-packages && export OPENWRT_PACKAGES_DIR=/tmp/openwrt-packages
	}
	[ -d "$OPENWRT_PACKAGES_DIR" ] && cd $OPENWRT_PACKAGES_DIR && {
		git checkout ${1:-master} || export OPENWRT_PACKAGES_DIR=
	}
	cd $CUR_DIR
	[ -z "$OPENWRT_PACKAGES_DIR" ] && return 1
	return 0
}

install_go() {
	GO_PATH=$(curl -skL 'https://go.dev/dl/' | grep -Eo 'href="/dl/[^"]+"' | sed -E 's/.*"(.*)"/\1/g' | grep 'amd64.*\.tar\.gz'| head -n1)
	[ -z "$GO_PATH" ] || {
		echo "Installing Go ..."
		GO_ROOT_DIR="$OPENWRT_ROOT_DIR/go"
		curl -kL "https://go.dev$GO_PATH" > /tmp/go.tar.gz && tar -xf /tmp/go.tar.gz -C $OPENWRT_ROOT_DIR && rm -f /tmp/go.tar.gz
		[ -d "$GO_ROOT_DIR/bin" ] && echo "GO_ROOT_DIR=$GO_ROOT_DIR" >> $GITHUB_ENV
		echo "Go Version: $($GO_ROOT_DIR/bin/go version)"
	}
	PACKAGES_GO_VERSION_CURRENT=$(cat $OPENWRT_ROOT_DIR/feeds/packages/lang/golang/*/Makefile | grep 'GO_VERSION_MAJOR_MINOR:=' | awk -F'=' '{print $2}' | head -n1)
	[ -z "$PACKAGES_GO_VERSION_CURRENT" ] || {
		[ "$(echo "$PACKAGES_GO_VERSION_CURRENT" | awk '{if ($0 < 1.24) {print "true"}}')" = "true" ] && rm -rf $OPENWRT_ROOT_DIR/feeds/packages/lang/golang && cp -rf $GITHUB_WORKSPACE/feeds/golang $OPENWRT_ROOT_DIR/feeds/packages/lang/golang
	}
	PACKAGES_GO_VERSION=$(cat $OPENWRT_ROOT_DIR/feeds/packages/lang/golang/*/Makefile | grep 'GO_VERSION_MAJOR_MINOR:=' | awk -F'=' '{print $2}' | head -n1)
	echo "PACKAGES_GO_VERSION: $PACKAGES_GO_VERSION"
}

fix_rust() {
	grep -Eq 'llvm.download-ci-llvm' $OPENWRT_ROOT_DIR/feeds/packages/lang/rust/Makefile && {
		echo "disable download llvm for rust ..."
		sed -Ei '/llvm.download-ci-llvm/d' $OPENWRT_ROOT_DIR/feeds/packages/lang/rust/Makefile
	}
}

fix_passwall_conflict() {
	[ -d "$OPENWRT_ROOT_DIR/package/custom/luci-app-passwall" ] && rm -rf $OPENWRT_ROOT_DIR/feeds/luci/applications/luci-app-passwall
	[ -d "$OPENWRT_ROOT_DIR/package/custom/luci-app-passwall2" ] && rm -rf $OPENWRT_ROOT_DIR/feeds/luci/applications/luci-app-passwall2
	[ -d "$OPENWRT_ROOT_DIR/package/custom/passwall" ] && {
		while read DIR; do
			[ -z "$DIR" ] && continue
			rm -rf "$OPENWRT_ROOT_DIR/feeds/packages/*/$DIR"
		done <<-EOF
		$(ls "$OPENWRT_ROOT_DIR/package/custom/passwall")
		EOF
	}
}

install_go
fix_rust
fix_passwall_conflict
