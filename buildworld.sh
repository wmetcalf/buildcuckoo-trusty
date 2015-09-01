#!/bin/sh
sudo apt-get update -y && sudo apt-get upgrade -y
sudo apt-get install -y vim screen unzip python python-dpkt python-jinja2 python-magic python-pymongo python-gridfs python-libvirt python-bottle python-chardet tcpdump clamav-daemon clamav-unofficial-sigs clamav clamav-base libcap2-bin python-dev build-essential subversion pcregrep libpcre++-dev python-pip ssdeep libfuzzy-dev git automake libtool autoconf libapr1 libapr1-dev libnspr4-dev libnss3-dev libwww-Perl libcrypt-ssleay-perl python-dev python-scapy python-yaml bison libpcre3-dev bison flex libdumbnet-dev autotools-dev libnet1-dev libpcap-dev libyaml-dev libnetfilter-queue-dev libprelude-dev zlib1g-dev libz-dev libcap-ng-dev libmagic-dev python-mysqldb lua-zip-dev lua-zip luarocks cmake libjansson-dev libswitch-perl libcdio-utils mongodb-server python-simplejson p7zip-full libzzip-dev python-geoip python-chardet python-m2crypto python-dnspython lua-bitop lua-zlib libcap2-bin zram-config 

sudo setcap cap_net_raw,cap_net_admin=eip /usr/sbin/tcpdump
sudo pip install bottle django pycrypto clamd distorm3 pygal django-ratelimit 
sudo luarocks install struct
sudo luarocks install lua-apr

#wget https://pefile.googlecode.com/files/pefile-1.2.10-139.tar.gz
tar -xzvf pefile-1.2.10-139.tar.gz
cd pefile-1.2.10-139
python setup.py build
sudo python setup.py install
cd ..

#yara
tar -zxf v3.4.0.tar.gz
cd yara-3.4.0
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

#volatility
tar -zxf volatility-2.4.tar.gz
cd volatility-2.4
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
sudo mkdir -p /usr/local/suricata/et-luajit-scripts/
sudo mkdir -p /usr/local/suricata/var/log
sudo mkdir -p /usr/local/suricata/var/run/suricata/
sudo mkdir -p /data/etc/
sudo apt-get install build-essential libapr1 libapr1-dev libnspr4-dev libnss3-dev libwww-Perl libcrypt-ssleay-perl python-dev python-scapy python-yaml bison libpcre3-dev bison flex libdumbnet-dev autotools-dev libnet1-dev libpcap-dev libyaml-dev libnetfilter-queue-dev libprelude-dev zlib1g-dev  libz-dev libcap-ng-dev libmagic-dev python-mysqldb lua-zip-dev luarocks cmake openvswitch-switch libaprutil1-dev libaprutil1-dbd-sqlite3 libapreq2-3 libapreq2-dev liblua5.1-0 liblua5.1-0-dev libapr1 libaprutil1 libaprutil1-dev libaprutil1-dbd-sqlite3 libapreq2-3 libapreq2-dev xrdp python-sqlalchemy -y 

git clone https://github.com/mkottman/ltn12ce
cd ltn12ce
mkdir build
cd build
cmake .. -DBUILD_ZLIB=Off -DLUA_LIBRARY=/usr/lib/x86_64-linux-gnu/liblua5.1.so -DLUA_INCLUDE_DIR=/usr/include/lua5.1/
make
sudo make install
cd ../..
sudo ln -s /usr/local/lib/lua/ltn12ce /usr/local/lib/lua/5.1/ltn12ce

luarocks download luazip
luarocks unpack luazip
rm luazip-1.2.4-1/luazip/src/luazip.c
cp -f luazip.c luazip-1.2.4-1/luazip/src/
cd luazip-1.2.4-1/luazip
sudo luarocks make luazip-1.2.4-1.rockspec
cd ../..

#wget http://www.openinfosecfoundation.org/download/suricata-2.0.7.tar.gz
#wget https://raw.githubusercontent.com/wmetcalf/buildcuckoo-trusty/master/suricata.yaml
tar -xzvf suricata-2.0.7.tar.gz
cd suricata-2.0.7
./configure --enable-profiling --prefix=/usr/local/suricata/ --with-libnss-includes=/usr/include/nss --with-libnss-libs=/usr/lib/nss --with-libnspr-includes=/usr/include/nspr --with-libnspr-libraries=/usr/lib/nspr --enable-lua --enable-unix-socket && make -j && sudo make install
sudo cp ../suricata.yaml /usr/local/suricata/etc/
sudo cp reference.config /usr/local/suricata/etc/
sudo cp classification.config /usr/local/suricata/etc/
cd ..

echo "alert http any any -> any any (msg:\"FILE store all\"; filestore; flowbits:noalert; sid:44444; rev:1;)" > local.rules
sudo cp local.rules /usr/local/suricata/etc/
#cp rules/files.rules /usr/local/suricata/etc/etpro/

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
disablesid=/usr/local/suricata/etc/disablesid.conf
engine=suricata
suricata_version=2.0.4
version=0.6.0
" > pp.config

#wget https://pulledpork.googlecode.com/files/pulledpork-0.6.1.tar.gz
tar -xzvf pulledpork-0.6.1.tar.gz
cd pulledpork-0.6.1
patch -p1 < ../pulledpork-etpro-fix.diff
sudo cp -f pulledpork.pl /usr/local/bin/
echo "#!/bin/sh
/usr/local/bin/pulledpork.pl -c /usr/local/suricata/etc/pp.config
cd /usr/local/suricata/et-luajit-scripts/ && git pull
cp -f /usr/local/suricata/et-luajit-scripts/*.lua /usr/local/suricata/etc/
cp -f /usr/local/suricata/et-luajit-scripts/d*.rules /usr/local/suricata/etc/
" > ruleupdates.sh
chmod +x ruleupdates.sh
echo "pcre:SURICATA (STMP|IP|TCP|ICMP|HTTP|STREAM)" >> etc/disablesid.conf 
echo "pcre:GPL NETBIOS" >> etc/disablesid.conf
sudo cp ruleupdates.sh /usr/local/bin/
sudo cp ../pp.config /usr/local/suricata/etc/
sudo cp etc/modifysid.conf /usr/local/suricata/etc/
sudo cp etc/enablesid.conf /usr/local/suricata/etc/
sudo cp etc/disablesid.conf /usr/local/suricata/etc/
cd ..
ruleupdates.sh

tar -xzvf moloch.tar.gz
cd moloch 
sudo ./easybutton-singlehost.sh
cd ..
sudo pkill -f "/data/moloch/bin/node viewer.js"
sudo pkill -f "/data/moloch/elasticsearch"


#sudo git clone https://github.com/EmergingThreats/cuckoo-1.1.git /data/cuckoo
git clone https://github.com/wmetcalf/cuckoo-modified cuckoo
cd cuckoo/utils
./community.py -a -f
cd ../..
sudo mv cuckoo /data/cuckoo

rm suricata-2.0.8 -Rf
rm pulledpork-0.6.1 -Rf
rm lua-zlib -Rf
rm ltn12ce -Rf
rm yara-3.4.0 -Rf
sudo rm volatility-2.4 -Rf
rm pydeep -Rf
sudo rm moloch -Rf
rm pp.config
sudo rm luazip-1.2.4-1.rockspec
sudo rm luazip-1.2.4-1 -Rf
sudo rm pefile-1.2.10-139 -Rf
 
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
sudo update-rc.d iptables defaults
sudo update-rc.d suricata defaults

echo "service /etc/init.d/openvswitch-switch restart
for tap in \`seq 0 4\`; do
 sudo ip tuntap add mode tap lan0p\$tap
done;
sudo ip tuntap list
for tap in \`seq 0 4\`; do
  sudo ip link set lan0p\$tap up
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

/etc/init.d/moloch start
/etc/init.d/cuckoo start
setcap cap_net_raw,cap_net_admin=eip /usr/sbin/tcpdump
exit 0" | sudo tee /etc/rc.local

CURRENT_USER=`whoami`
sudo chown $CURRENT_USER:$CURRENT_USER /usr/local/suricata/ -Rf
sudo chown $CURRENT_USER:$CURRENT_USER /data/moloch -Rf
sudo chown $CURRENT_USER:$CURRENT_USER /data/cuckoo -Rf
sudo usermod -a -G cuckoo clamav

echo "/data/cuckoo/storage/** r," | sudo tee /etc/apparmor.d/local/usr.sbin.clamd

echo "deb http://download.virtualbox.org/virtualbox/debian trusty contrib" |sudo tee -a /etc/apt/sources.list
wget -q http://download.virtualbox.org/virtualbox/debian/oracle_vbox.asc -O- | sudo apt-key add -
sudo apt-get update
sudo apt-get install virtualbox-4.3 -y

echo xfce4-session > ~/.xsession
sudo service xrdp restart

sudo virsh net-destroy default
sudo virsh net-undefine default
sudo service libvirtd restart

echo "#!/bin/sh
su cuckoo -c \"/usr/local/bin/ruleupdates.sh\" && /etc/init.d/suricata restart" | sudo tee /etc/cron.daily/ruleupdates
sudo chmod +x /etc/cron.daily/ruleupdates
