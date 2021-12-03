#!/bin/bash
latestVer=$(curl 'https://repo.nordvpn.com/deb/nordvpn/debian/pool/main/' | 
 egrep -o 'href="nordvpn_[0-9]+\.[0-9]+\.[0-9]+[-]?[0-9]+?' | sed 's/^href="nordvpn_//' |
 sort -t. -rn -k1,1 -k2,2 -k3,3 | head -1)
PACKAGE="nordvpn_${latestVer}_amd64.deb"
DIR="/tmp/nordvpn_$(date +%s)"

sudo eopkg upgrade
sudo eopkg install ipset ipset-devel binutils

[ -d $DIR ] || mkdir $DIR
cd $DIR

echo "Downloading $PACKAGE"
wget https://repo.nordvpn.com/deb/nordvpn/debian/pool/main/$PACKAGE
if [ ! -f $PACKAGE ]; then
    echo "Couldn't download $PACKAGE"
    exit
fi

ar x $PACKAGE
tar -xvf data.tar.gz --one-top-level

cd data
sudo cp -R etc/* /etc/
sudo cp -R usr/bin/* /usr/bin/
sudo cp -R usr/lib/* /usr/lib/
sudo cp -R usr/sbin/* /usr/sbin/
sudo cp -R usr/share/* /usr/share/
sudo cp -R var/* /var/

sudo systemctl enable nordvpnd.socket
sudo systemctl enable nordvpnd.service
sudo systemctl start nordvpnd.socket
sudo systemctl start nordvpnd.service
mkdir -p /dev/net
sudo ln -s /sbin/ip /usr/sbin/ip 
/etc/init.d/nordvpn restart &>/dev/null

sudo usermod -aG nordvpn $USER

echo "Installation is complete!"