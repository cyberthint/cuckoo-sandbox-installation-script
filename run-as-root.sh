#!/bin/sh

printf "\n>>> UPDATE : Apt Manager...\n\n"

sudo apt update
sudo apt upgrade

printf "\n>>> INSTALL : Neccessary packages...\n\n"

sudo apt-get install -y software-properties-common build-essential \
    python python-pip python-dev libffi-dev libssl-dev \
    python-virtualenv python-setuptools \
    libjpeg-dev zlib1g-dev swig libpq-dev \
    tcpdump apparmor-utils genisoimage

printf "\n>>> INSTALL : Docker packages...\n\n"

sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

printf "\n>>> INSTALL : Docker-compose packages...\n\n"

sudo curl -L "https://github.com/docker/compose/releases/download/1.28.5/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

printf "\n>>> SETTINGS : Creating User and Group for Cuckoo\n\n"

sudo adduser --disabled-password --gecos "" cuckoo
sudo groupadd pcap
sudo usermod -a -G pcap cuckoo
sudo chgrp pcap /usr/sbin/tcpdump
sudo setcap cap_net_raw,cap_net_admin=eip /usr/sbin/tcpdump

printf "\n>>> USER : User settings and manage files...\n\n"

sudo aa-disable /usr/sbin/tcpdump

cp ./run-as-cuckoo.sh /home/cuckoo/run-as-cuckoo.sh
chown cuckoo:cuckoo /home/cuckoo/run-as-cuckoo.sh
chmod a+x /home/cuckoo/run-as-cuckoo.sh

cp ./services/start-cuckoo.sh /home/cuckoo/start-cuckoo.sh
chown cuckoo:cuckoo /home/cuckoo/start-cuckoo.sh
chmod a+x /home/cuckoo/start-cuckoo.sh

cp -R ./conf /home/cuckoo/conf
chown -R cuckoo:cuckoo /home/cuckoo/conf

printf "\n>>> INSTALL : Installing and mount win7 image\n\n"

wget https://cuckoo.sh/win7ultimate.iso
mkdir /mnt/win7
sudo mount -o ro,loop win7ultimate.iso /mnt/win7

printf "\n>>> INSTALL : Downloading virtualbox...\n\n"

wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc -O- | sudo apt-key add -
wget -q https://www.virtualbox.org/download/oracle_vbox.asc -O- | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] http://download.virtualbox.org/virtualbox/debian $(lsb_release -cs) contrib"
sudo apt-get update
sudo apt-get install -y virtualbox-5.2
sudo usermod -a -G vboxusers cuckoo

printf "\n>>> SETTINGS : Settings up virtualbox network settings... \n\n"

vboxmanage hostonlyif create
echo 1 | sudo tee -a /proc/sys/net/ipv4/ip_forward
sudo sysctl -w net.ipv4.ip_forward=1

printf "\n>>> SERVICE : Create docker-compose service\n\n"

cp ./docker-compose.yml /start-cuckoo-services.yml
cp ./services/cuckoo-docker.service /etc/systemd/system/cuckoo-docker.service
systemctl enable cuckoo-docker.service

printf "\n>>> SERVICE : Create cuckoo settings service\n\n"

cp ./services/cuckoo-settings.service /etc/systemd/system/cuckoo-settings.service
systemctl enable cuckoo-settings.service

printf "\n>>> SERVICE : Create cuckoo service\n\n"

cp ./services/cuckoo.service /etc/systemd/system/cuckoo.service
systemctl enable cuckoo.service

printf "\n>>> SERVICE : Create cuckoo web service\n\n"

cp ./services/cuckoo-web.service /etc/systemd/system/cuckoo-web.service
systemctl enable cuckoo-web.service

printf "\n>>> SERVICE : Create cuckoo web service\n\n"

cp ./services/cuckoo-api.service /etc/systemd/system/cuckoo-api.service
systemctl enable cuckoo-api.service