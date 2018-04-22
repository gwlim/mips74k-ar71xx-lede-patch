#!/bin/bash
set -e
echo Add QCA Repo
wget https://source.codeaurora.org/quic/qsdk/oss/system/openwrt/plain/include/local-development.mk -P ./include/
sed -i 's|git describe --dirty|git describe|g' ./include/local-development.mk
sed -i 's|$(TOPDIR)/qca/src/$(PKG_NAME)|$(TOPDIR)/package/qca/$(PKG_NAME)/src|g' ./include/local-development.mk
echo 'src-git ssdk https://source.codeaurora.org/quic/qsdk/oss/ssdk-shell' >> ./feeds.conf.default
echo 'src-git shortcutfe https://source.codeaurora.org/quic/qsdk/oss/system/feeds/shortcut-fe?h=release/endive_mips' >> ./feeds.conf.default
# echo 'src-git nsshost https://source.codeaurora.org/quic/qsdk/oss/system/feeds/nss-host' >> ./feeds.conf.default
./scripts/feeds update -a
echo Clone QCA SRC
git clone https://source.codeaurora.org/quic/qsdk/oss/lklm/qca-ssdk ./feeds/ssdk/qca-ssdk/src -b release/endive_mips
git clone https://source.codeaurora.org/quic/qsdk/oss/ssdk-shell ./feeds/ssdk/qca-ssdk-shell/src -b release/endive_mips
# git clone https://source.codeaurora.org/quic/qsdk/oss/lklm/qca-rfs ./feeds/nsshost/qca-rfs/src
mkdir -p ./package/qca/
mv ./feeds/ssdk/* ./package/qca
mv ./feeds/shortcutfe/* ./package/qca
# Delete the last 2 lines of feed conf because Repositories DO NOT EXIST
sed -i '$d' feeds.conf.default
sed -i '$d' feeds.conf.default
#mkdir -p ./package/nsshost/qca-rfs/
#mv ./feeds/nsshost/qca-rfs/ ./package/nsshost
sed -i 's|+kmod-ipt-extra +kmod-ipt-filter +kmod-ipv6 |+kmod-ipt-extra +kmod-ipt-filter |g' ./package/qca/qca-ssdk/Makefile
./scripts/feeds install -a
echo Remove Support for PPPOA
rm ./feeds/luci/protocols/luci-proto-ppp/luasrc/model/cbi/admin_network/proto_pppoa.lua
echo Remove AICCU Obsolete
rm ./feeds/luci/protocols/luci-proto-ipv6/luasrc/model/network/proto_aiccu.lua
rm ./feeds/luci/protocols/luci-proto-ipv6/luasrc/model/cbi/admin_network/proto_aiccu.lua
echo Remove Support for DIR-825 and AllNet Devices
rm ./target/linux/ar71xx/base-files/lib/upgrade/dir825.sh
rm ./target/linux/ar71xx/base-files/lib/upgrade/allnet.sh
rm ./target/linux/ar71xx/base-files/lib/upgrade/merakinand.sh
        for i in $( ls patch ); do
            echo Applying patch $i
            patch -p1 < patch/$i
        done
wget http://dl.google.com/closure-compiler/compiler-latest.zip
wget https://github.com/yui/yuicompressor/releases/download/v2.4.8/yuicompressor-2.4.8.jar
unzip -qn compiler-latest.zip
directory=./feeds
for file in $( find $directory -name '*.js' )
do
  if [[ $file == *arduino* ]]
  then
  echo Skipping $file
      continue
  fi
  echo Compiling $file
  java -jar closure-compiler-*.jar --warning_level QUIET --compilation_level=SIMPLE_OPTIMIZATIONS --js="$file" --js_output_file="$file-min.js"
  mv -b "$file-min.js" "$file"
done

for file in $( find $directory -name '*.css' )
do
  echo Minifying $file
  java -jar yuicompressor-2.4.8.jar -o "$file-min.css" "$file"
  mv -b "$file-min.css" "$file"
done
sed -i 's|-O2 -fno-pic -pipe -mabi=32 -march=mips32r2|-O2 -fno-pic -pipe -mabi=32 -march=74kc|g' ./package/qca/qca-ssdk/src/make/linux_opt.mk ./package/qca/qca-ssdk/src/config ./package/qca/qca-ssdk-shell/src/make/linux_opt.mk ./package/qca/qca-ssdk-shell/src/config
sed -i 's|-mlong-calls|-mno-long-calls -mno-mips16 -mno-interlink-compressed -msym32 -mframe-header-opt -fno-caller-saves -fno-plt -DNDEBUG|g' ./package/qca/qca-ssdk/src/make/linux_opt.mk ./package/qca/qca-ssdk/src/config ./package/qca/qca-ssdk-shell/src/make/linux_opt.mk ./package/qca/qca-ssdk-shell/src/config
make defconfig
rm .config
make defconfig
