#!/bin/sh
sudo apt-get update -y && sudo apt-get upgrade -y
sudo apt-get install -y python python-dpkt python-jinja2 python-magic python-pymongo python-gridfs python-libvirt python-bottle python-chardet tcpdump clamav-daemon clamav-unofficial-sigs clamav clamav-base libcap2-bin python-dev build-essential subversion pcregrep libpcre++-dev python-pip ssdeep libfuzzy-dev git automake libtool autoconf libapr1 libapr1-dev libnspr4-dev libnss3-dev libwww-Perl libcrypt-ssleay-perl python-dev python-scapy python-yaml bison libpcre3-dev bison flex libdumbnet-dev autotools-dev libnet1-dev libpcap-dev libyaml-dev libnetfilter-queue-dev libprelude-dev zlib1g-dev  libz-dev libcap-ng-dev libmagic-dev python-mysqldb liblua5.1-zip-dev luarocks cmake libjansson-dev

sudo setcap cap_net_raw,cap_net_admin=eip /usr/sbin/tcpdump
sudo pip install bottle pefile django pycrypto

#wget https://distorm.googlecode.com/files/distorm3.zip
unzip distorm3.zip
cd distorm3
python setup.py build
sudo python setup.py install
cd ..

#wget https://github.com/plusvic/yara/archive/2.1.0.tar.gz
tar -zxf 2.1.0.tar.gz
cd yara-2.1.0
./bootstrap.sh
chmod +x build.sh
./build.sh
sudo make install

echo "/usr/local/lib" | sudo tee /etc/ld.so.conf.d/cuckoo
sudo ldconfig
cd yara-python
python setup.py build
sudo python setup.py install
cd ../..

#wget http://volatility.googlecode.com/files/volatility-2.3.1.tar.gz
tar -zxf volatility-2.3.1.tar.gz
cd volatility-2.3.1
python setup.py build
sudo python setup.py install
cd ..

git clone https://github.com/kbandla/pydeep.git
cd pydeep
python setup.py build
sudo python setup.py install
cd ..

sudo mkdir -p /usr/local/suricata/bin
sudo mkdir -p /usr/local/suricata/lib
sudo mkdir -p /usr/local/suricata/lib
sudo mkdir -p /usr/local/suricata/include/linux
sudo mkdir -p /usr/local/suricata/sbin
sudo mkdir -p /usr/local/suricata/etc/
sudo mkdir -p /usr/local/suricata/etc/
sudo mkidr -p /usr/local/suricata/et-luajit-scripts/
sudo mkdir -p /usr/local/suricata/var/log
sudo mkdir -p /usr/local/suricata/var/run/suricata/
sudo apt-get install build-essential libapr1 libapr1-dev libnspr4-dev libnss3-dev libwww-Perl libcrypt-ssleay-perl python-dev python-scapy python-yaml bison libpcre3-dev bison flex libpcap-ruby libdumbnet-dev autotools-dev libnet1-dev libpcap-dev libyaml-dev libnetfilter-queue-dev libprelude-dev zlib1g-dev  libz-dev libcap-ng-dev libmagic-dev python-mysqldb liblua5.1-zip-dev luarocks cmake openvswitch-switch libaprutil1-dev libaprutil1-dbd-sqlite3 libapreq2 libapreq2-dev -y 

#wget ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-8.35.tar.gz
tar -xzvf pcre-8.35.tar.gz
cd pcre-8.35
./configure --prefix=/usr/local/pcre-8.35/ --enable-jit --enable-utf8 --enable-unicode-properties
make -j && sudo make install
cd ..

#wget http://luajit.org/download/LuaJIT-2.0.3.tar.gz
tar -xzvf LuaJIT-2.0.3.tar.gz
cd LuaJIT-2.0.3
make -j
sudo make install
cd ..
sudo ldconfig
echo "/usr/local/luajit20/lib/" | sudo tee /etc/ld.so.conf.d/suricata.conf
echo "/usr/local/pce-8.35/lib/" | sudo tee -a /etc/ld.so.conf.d/suricata.conf

sudo ldconfig

sudo luarocks install struct
sudo luarocks install lua-apr

mkdir lua-zlib
cd lua-zlib
git clone https://github.com/brimworks/lua-zlib.git
cmake lua-zlib
sudo make install
cd ..

git clone https://github.com/mkottman/ltn12ce
cd ltn12ce
mkdir build
cd build
cmake .. -DBUILD_ZLIB=Off
make
sudo make install
cd ../..

sudo ln -s /usr/lib/x86_64-linux-gnu/lua/5.1/zip.so /usr/local/lib/lua/5.1/zip.so
sudo ln -s /usr/local/lib/lua/apr /usr/local/lib/lua/5.1/apr
sudo ln -s /usr/local/lib/lua/ltn12ce /usr/local/lib/lua/5.1/ltn12ce 
sudo ln -s /usr/local/share/lua/cmod/zlib.so /usr/local/lib/lua/5.1/zlib.so
#wget http://www.openinfosecfoundation.org/download/suricata-1.4.7.tar.gz
tar -xzvf suricata-1.4.7.tar.gz
cd suricata-1.4.7
./configure LD_RUN_PATH="/usr/local/pcre-8.35/lib:/usr/local/luajit20/lib/:/usr/local/lib/:/usr/lib:/usr/local/lib" --enable-pcre-jit --with-libpcre-libraries=/usr/local/pcre-8.35/lib/ --with-libpcre-includes=/usr/local/pcre-8.35/include/ --enable-profiling --prefix=/usr/local/suricata/ --with-libnss-includes=/usr/include/nss --with-libnss-libs=/usr/lib/nss --with-libnspr-includes=/usr/include/nspr --with-libnspr-libraries=/usr/lib/nspr --enable-luajit --with-libluajit-includes=/usr/local/include/luajit-2.0/ --with-libluajit-libraries=/usr/local/lib/ --enable-unix-socket && make -j && sudo make install
sudo cp ../suricata.yaml /usr/local/suricata/etc/
sudo cp reference.config /usr/local/suricata/etc/
sudo cp classification.config /usr/local/suricata/etc/
#cp rules/files.rules /usr/local/suricata/etc/etpro/
cd ..

sudo git clone https://github.com/EmergingThreats/et-luajit-scripts /usr/local/suricata/et-luajit-scripts
sudo cp /usr/local/suricata/et-luajit-scripts/* /usr/local/suricata/etc/
read -p  "Enter your ETPRO oinkcode if you have one [ENTER]: " oinkcode
if ["$oinkcode" = ""]; then
 rule_url="https://rules.emergingthreatspro.com/|emerging.rules.tar.gz|open"
else
 rule_url="https://rules.emergingthreatspro.com/|etpro.rules.tar.gz|$oinkcode"
fi

echo "rule_url=$rule_url
ignore=local.rules
temp_path=/tmp
rule_path=/usr/local/suricata/etc/all.rules
sid_msg=/usr/local/suricata/etc/sid-msg.map
sid_changelog=/usr/local/suricata/var/log/etpro_sid_changes.log
engine=suricata
suricata_version=1.4.7
version=0.6.0
" > pp.config

#wget https://pulledpork.googlecode.com/files/pulledpork-0.6.1.tar.gz
tar -xzvf pulledpork-0.6.1.tar.gz
cd pulledpork-0.6.1
patch -p1 < ../pulledpork-etpro-fix.diff
sudo cp -f pulledpork.pl /usr/local/bin/
echo "#!/bin/sh
/usr/local/bin/pulledpork.pl -c /usr/local/suricata/etc/pp.config -K /usr/local/suricata/etc/
cd /usr/local/suricata/et-luajit-scripts/ && git pull
" > ruleupdates.sh
chmod +x ruleupdates.sh
sudo cp ruleupdates.sh /usr/local/bin/
sudo cp ../pp.config /usr/local/suricata/etc/
sudo cp etc/modifysid.conf /usr/local/suricata/etc/
sudo cp etc/enablesid.conf /usr/local/suricata/etc/
sudo cp etc/disablesid.conf /usr/local/suricata/etc/
cd ..

unzip moloch-master.zip
cd moloch-master
sudo ./easybutton-singlehost.sh
cd ..
sudo pkill -f "/data/moloch/bin/node viewer.js"
sudo pkill -f "/data/moloch/elasticsearch-0"


sudo git clone https://github.com/EmergingThreats/cuckoo-1.1.git /data/cuckoo

rm pcre-8.35 -Rf
rm suricata-1.4.7 -Rf
rm pulledpork-0.6.1 -Rf
rm LuaJIT-2.0.3 -Rf
rm lua-zlib -Rf
rm ltn12ce -Rf
rm yara-2.1.0 -Rf
sudo rm volatility-2.3.1 -Rf
rm pydeep -Rf
rm distorm3 -Rf
sudo rm moloch-master -Rf
rm pp.config
 
#!/bin/sh
sudo ovs-vsctl add-br lan0
for tap in `seq 0 4`; do
        sudo ip tuntap add mode tap lan0p$tap
done;
sudo ip tuntap list
for tap in `seq 0 4`; do
        sudo ip link set lan0p$tap up
done;
sudo ip link
for tap in `seq 0 4`; do
       sudo ovs-vsctl add-port lan0 lan0p$tap
done;
sudo ovs-vsctl list-ports lan0
#sudo ovs-vsctl -- --id=@m create mirror name=mirror3 select_all=1 -- add bridge lan0 mirrors @m
#mirror port
sudo modprobe dummy
sudo ip link set up dummy0
sudo ifconfig dummy0 promisc -arp
sudo ovs-vsctl -- --may-exist add-port lan0 dummy0
sudo ovs-vsctl -- --id=@p get port dummy0 -- --id=@m create mirror name=mirror0 select_all=1 -- add bridge lan0 mirrors @m -- set mirror mirror0 output_port=@p
#mgmt
sudo ovs-vsctl add-port lan0 lan0hp0 -- set interface lan0hp0 type=internal
sudo ip addr add 192.168.1.1 dev lan0hp0
sudo ip link set lan0hp0 up
sudo ip route add 192.168.1.0/24 dev lan0hp0

chmod +x services/*
sudo cp services/* /etc/init.d/

echo "service /etc/init.d/openvswitch-switch restart
for tap in `seq 0 4`; do
 sudo ip tuntap add mode tap lan0p$tap
done;
sudo ip tuntap list
for tap in `seq 0 4`; do
  sudo ip link set lan0p$tap up
done;
sudo ip link

#mirror port
sudo modprobe dummy
sudo ip link set up dummy0
sudo ifconfig dummy0 promisc -arp
#mgmt
sudo ip addr add 192.168.1.1 dev lan0hp0
sudo ip link set lan0hp0 up
sudo ip route add 192.168.1.0/24 dev lan0hp0

/etc/init.d/suricata start
/etc/init.d/moloch start
/etc/init.d/cuckoo start
exit 0" | sudo tee /etc/rc.local

CURRENT_USER=`whoami`
sudo chown $CURRENT_USER:$CURRENT_USER /usr/local/suricata/ -Rf
sudo chown $CURRENT_USER:$CURRENT_USER /data/moloch -Rf
sudo chown $CURRENT_USER:$CURRENT_USER /data/cuckoo -Rf
sudo usermod -a -G cuckoo clamav

echo "/data/cuckoo/storage/** r," | sudo tee /etc/apparmor.d/local/usr.sbin.clamd

echo "deb http://download.virtualbox.org/virtualbox/debian trusty contrib" |sudo tee /etc/apt/sources.list
wget -q http://download.virtualbox.org/virtualbox/debian/oracle_vbox.asc -O- | sudo apt-key add -
sudo apt-get update
sudo apt-get install virtualbox-4.3
