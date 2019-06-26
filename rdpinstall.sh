#!/bin/sh

echo "Going to run 1st RPM package"
echo "*****************************"

rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm

echo "Going to run 2nd RPM package"
echo "******************************"

rpm -Uvh http://li.nux.ro/download/nux/dextop/el7/x86_64/nux-dextop-release-0-1.el7.nux.noarch.rpm

printf '[xrdp]\nname=xrdp\nbaseurl=http://li.nux.ro/download/nux/dextop/el7/x86_64/\nenabled=1\ngpgcheck=0' >> /etc/yum.repos.d/xrdp.repo

echo "Installing tigervnc server"
echo "******************************"

yum -y install xrdp tigervnc-server

echo "Starting up xrdp service"
echo "******************************"

systemctl start xrdp.service

echo "Enabling xrdp service"
echo "******************************"

systemctl enable xrdp.service

firewall-cmd --permanent --zone=public --add-port=3389/tcp

firewall-cmd --reload

netstat -antup | grep xrdp

echo "******************************"
echo "Everything is ok"

yum groupinstall "Server with GUI" -y

echo "Installing desktop gui"

#yum update grub2-common
#yum install fwupdate-efi
#yum groupinstall "Server with GUI" -y --skip-broken
