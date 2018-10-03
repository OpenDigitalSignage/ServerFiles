#!/bin/sh

##################################################
# Ubuntu 18.04.1 LTS (Bionic Beaver)             #
# iso: ubuntu-18.04.1-live-server-amd64.iso      #
##################################################

##################################################
# /TR 2018-10-03
##################################################

add-apt-repository universe
apt update -y
apt upgrade -y

# install ssmtp as mail provider, so we don't get the postfix + mysql
apt install -y ssmtp bsd-mailx

# install needed packages:
apt install -y inotify-tools samba imagemagick libreoffice-common \
 unoconv mupdf-tools mini-httpd dos2unix htop mc bash-completion

# these are not really needed, but I like to have them ;)
apt install -y pacapt smartmontools sshfs

# configure samba
cat << EOF > /etc/samba/smb.conf

# edit to fit your wanted IP's
# /TR 2018-09-30
[global]
    workgroup = WORKGROUP
    server string = ds-server
    log file = /var/log/samba/log.%m
    max log size = 50
    client signing = required
    load printers = No
    printcap name = /dev/null
    disable spoolss = Yes
    browseable = Yes
    hosts allow = 127., 10., 192.

[dsbd-sample]
    comment = DSBD
    path = /home/dsbd/dsbd-sample
    read only = No

# you may use multiple instances (groups of displays)
# [dsbd-sample2]
#     comment = DSBD
#     path = /home/dsbd/dsbd-sample2
#     read only = No
EOF

# configure mini-httpd
sed -i /etc/mini-httpd.conf \
 -e 's/^host=.*/host=0.0.0.0/g' \
 -e 's/^charset=.*/charset=utf8/g'

mkdir -p /root/tmp
cd /root/tmp || exit
git clone --depth=1 https://github.com/OpenDigitalSignage/ServerFiles
SRC="/root/tmp/ServerFiles"

# copy template files
cd $SRC/var/lib || exit
cp -r dsbd /var/lib/dsbd

# copy dsbd script and one service example file
cd $SRC/distrib/Ubuntu-18.04-LTS || exit

# copy dsbd script to /usr/sbin
cp sbin/dsbd /usr/sbin

# create service example
mkdir -p /etc/dsbd.d
cp etc-dsbd.d/dsbd-reload /etc/dsbd.d
cp etc-dsbd.d/dsbd-sample.service /etc/dsbd.d

# create as much services as you have TV groups
systemctl link /etc/dsbd.d/dsbd-sample.service
systemctl enable dsbd-sample
systemctl restart dsbd-sample

# last thing, add smb user with some password
# smbpasswd -a dsbd
