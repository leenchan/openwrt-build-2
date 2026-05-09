#!/bin/sh

# sudo apt install libfuse-dev
# rm -rf feeds/packages/lang/golang
# git clone https://github.com/sbwml/packages_lang_golang -b 24.x feeds/packages/lang/golang

# Fix compile nginx-mod-njs
# grep -Eq 'NGX_LD_OPT' feeds/packages/net/nginx/patches/nginx-mod-njs/104-endianness_fix.patch || {
#   cp -f $GITHUB_WORKSPACE/feeds/nginx/patches/nginx-mod-njs/104-endianness_fix.patch feeds/packages/net/nginx/patches/nginx-mod-njs/104-endianness_fix.patch
# }
