#!/bin/sh

git clone https://github.com/gdy666/luci-app-lucky.git package/lucky
git clone https://github.com/sbwml/luci-app-openlist2 package/openlist2
git clone --recurse-submodules https://${GH_TOKEN}@github.com/leenchan/openwrt-package-custom.git package/custom
# Fix compile quickfile for aarch64
[ -f ./package/custom/quickfile/quickfile/Makefile ] && sed -Ei "s|.*ARCH_PACKAGES.*|ifeq (\$(ARCH),aarch64)\n	\$(INSTALL_BIN) \$(PKG_BUILD_DIR)/quickfile-aarch64_generic \$(1)/usr/bin/quickfile\nelse\n	\$(INSTALL_BIN) \$(PKG_BUILD_DIR)/quickfile-\$(ARCH) \$(1)/usr/bin/quickfile\nendif|g" ./package/custom/quickfile/quickfile/Makefile
