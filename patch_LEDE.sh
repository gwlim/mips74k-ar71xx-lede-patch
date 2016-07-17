#!/bin/bash
set -e
./scripts/feeds update -a
./scripts/feeds install -a
echo Remove Support for PPPOA
rm ./feeds/luci/protocols/luci-proto-ppp/luasrc/model/cbi/admin_network/proto_pppoa.lua
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