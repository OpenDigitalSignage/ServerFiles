#!/bin/sh

##################################################
# Ubuntu 18.04.1 LTS (Bionic Beaver)             #
# iso: ubuntu-18.04.1-live-server-amd64.iso      #
##################################################

##################################################
# /TR 2018-09-30
##################################################
SERVERNAME="ds-server"

mkdir -p /root/tmp
cd /root/tmp || exit
git clone --depth=1 https://github.com/OpenDigitalSignage/ServerFiles

add-apt-repository universe
apt update -y
apt upgrade -y

# install ssmtp as mail provider, so we don't get the postfix mess
apt install -y ssmtp

# install needed packages:
apt install -y inotify-tools samba imagemagick libreoffice-common \
 unoconv mupdf-toolsmicro-httpd dos2unix htop

# these are not really needed, but I like want these:
apt install -y pacapt mc bash-completion smartmontools sshfs

# configure samba
cat << EOF > /etc/samba/smb.conf

# edit to fit your wanted IP's
# /TR 2018-09-30
[global]
    workgroup = WORKGROUP
    server string = $SERVERNAME
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

[dsbd-sample2]
    comment = DSBD
    path = /home/dsbd/dsbd-sample2
    read only = No
EOF

# configure mini-httpd
sed -i /etc/mini-httpd.conf \
 -e 's/^host=.*/host=0.0.0.0/g' \
 -e 's/^charset=.*/charset=utf8/g'

# last thing, add an smb user:
# smbpasswd -a dsbd

#############################################################################
# - now you have to add the init scripts you want to /etc/rc.d/init.d
# - source: https://github.com/OpenDigitalSignage/ServerFiles/distrib/Ubuntu-18.04-LTS
#
# 1) cp $url/etc-dsb.d/dsb-reload /etc/dsb.d/dsb-reload
# 1) cp $url/etc-dsb.d/dsbs-sample.service /etc/dsb.d/dsbs-sample.service
# 1) cp $url/etc-dsb.d/dsbs-sample.service /etc/dsb.d/dsbs-sample.service
# 2) cp $url/sbin/dsbd /usr/sbin/dsbd
# 3) cp $url/sbin/dsbs /usr/sbin/dsbs
# 4) add systemd files to /etc/dsb.d
# 5) check the dsbd-sample.service and the dsbs-sample.service
# 6) create services like them and put symbolic links to /etc/systemd/system
#############################################################################
