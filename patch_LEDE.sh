#!/bin/bash
set -e
echo Add QCA Repo
wget https://source.codeaurora.org/quic/qsdk/oss/system/openwrt/plain/include/local-development.mk -P ./include/
sed -i 's|$(TOPDIR)/qca/src/$(PKG_NAME)|$(TOPDIR)/package/ssdk/$(PKG_NAME)/src|g' ./include/local-development.mk
echo 'src-git ssdk https://source.codeaurora.org/quic/qsdk/oss/system/feeds/ssdk.git' >> ./feeds.conf.default
# echo 'src-git nsshost https://source.codeaurora.org/quic/qsdk/oss/system/feeds/nss-host.git' >> ./feeds.conf.default
./scripts/feeds update -a
echo Clone QCA SRC
git clone -b release/dandelion https://source.codeaurora.org/quic/qsdk/oss/lklm/qca-ssdk.git ./feeds/ssdk/qca-ssdk/src
git clone https://source.codeaurora.org/quic/qsdk/oss/ssdk-shell.git ./feeds/ssdk/qca-ssdk-shell/src
# git clone https://source.codeaurora.org/quic/qsdk/oss/lklm/qca-rfs ./feeds/nsshost/qca-rfs/src
mv ./feeds/ssdk ./package/
#mkdir -p ./package/nsshost/qca-rfs/
#mv ./feeds/nsshost/qca-rfs/ ./package/nsshost
sed -i 's|+kmod-ipt-extra +kmod-ipt-filter +kmod-ipv6 +(TARGET_ipq806x||TARGET_ipq):kmod-qca-rfs +kmod-ppp|+kmod-ipt-extra +kmod-ipt-filter +(TARGET_ipq806x||TARGET_ipq):kmod-qca-rfs +kmod-ppp|g' ./package/ssdk/qca-ssdk/Makefile
./scripts/feeds install -a
echo Remove Support for PPPOA
rm ./feeds/luci/protocols/luci-proto-ppp/luasrc/model/cbi/admin_network/proto_pppoa.lua
rm ./target/linux/ar71xx/patches-4.4/910-unaligned_access_hacks.patch
echo Remove Support for DIR-825 and AllNet Devices
rm ./target/linux/ar71xx/base-files/lib/upgrade/dir825.sh
rm ./target/linux/ar71xx/base-files/lib/upgrade/allnet.sh
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
sed -i 's|-O2 -fno-pic -pipe -mabi=32 -march=mips32r2|-O2 -fno-pic -pipe -mabi=32 -march=74kc|g' ./package/ssdk/qca-ssdk/src/make/linux_opt.mk ./package/ssdk/qca-ssdk/src/config ./package/ssdk/qca-ssdk-shell/src/make/linux_opt.mk ./package/ssdk/qca-ssdk-shell/src/config
sed -i 's|-mlong-calls|-mno-long-calls|g' ./package/ssdk/qca-ssdk/src/make/linux_opt.mk ./package/ssdk/qca-ssdk/src/config ./package/ssdk/qca-ssdk-shell/src/make/linux_opt.mk ./package/ssdk/qca-ssdk-shell/src/config 
#for file in $( find $directory -name '*.htm' )
#do
#  echo Minifying $file
#  java -jar htmlcompressor-1.5.3.jar -o "$file-min.htm" "$file"
#  mv -b "$file-min.htm" "$file"
#done

#echo Restore missing Layer 7 Patterns
#wget http://download.clearfoundation.com/l7-filter/l7-protocols-2009-05-28.tar.gz
#tar -zxf l7-protocols-2009-05-28.tar.gz
#mkdir -p ./package/network/utils/iptables/files/l7/
#cp  ./l7-protocols-2009-05-28/protocols/aim.pat  ./package/network/utils/iptables/files/l7/
#cp  ./l7-protocols-2009-05-28/protocols/bittorrent.pat  ./package/network/utils/iptables/files/l7/
#cp  ./l7-protocols-2009-05-28/protocols/edonkey.pat  ./package/network/utils/iptables/files/l7/
#cp  ./l7-protocols-2009-05-28/protocols/fasttrack.pat  ./package/network/utils/iptables/files/l7/
#cp  ./l7-protocols-2009-05-28/protocols/ftp.pat  ./package/network/utils/iptables/files/l7/
#cp  ./l7-protocols-2009-05-28/protocols/gnutella.pat  ./package/network/utils/iptables/files/l7/
#cp  ./l7-protocols-2009-05-28/protocols/http.pat  ./package/network/utils/iptables/files/l7/
#cp  ./l7-protocols-2009-05-28/protocols/ident.pat  ./package/network/utils/iptables/files/l7/
#cp  ./l7-protocols-2009-05-28/protocols/irc.pat  ./package/network/utils/iptables/files/l7/
#cp  ./l7-protocols-2009-05-28/protocols/jabber.pat  ./package/network/utils/iptables/files/l7/
#cp  ./l7-protocols-2009-05-28/protocols/msnmessenger.pat  ./package/network/utils/iptables/files/l7/
#cp  ./l7-protocols-2009-05-28/protocols/ntp.pat  ./package/network/utils/iptables/files/l7/
#cp  ./l7-protocols-2009-05-28/protocols/pop3.pat  ./package/network/utils/iptables/files/l7/
#cp  ./l7-protocols-2009-05-28/protocols/smtp.pat  ./package/network/utils/iptables/files/l7/
#cp  ./l7-protocols-2009-05-28/protocols/ssl.pat  ./package/network/utils/iptables/files/l7/
#cp  ./l7-protocols-2009-05-28/protocols/vnc.pat  ./package/network/utils/iptables/files/l7/

make defconfig
rm .config
make defconfig