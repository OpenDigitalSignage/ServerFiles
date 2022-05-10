#!/bin/bash

timedatectl set-timezone Europe/Berlin

# utf8 deutsch
sed -i /etc/locale.gen -e 's/^# de_DE.UTF-8/de_DE.UTF-8/g'
locale-gen

# generic repo
cat <<EOF > /etc/apt/sources.list
deb http://ftp.debian.org/debian bullseye main contrib
deb http://ftp.debian.org/debian bullseye-updates main contrib
deb http://security.debian.org/debian-security bullseye-security main contrib
EOF

# update
apt update -y
apt upgrade -y

apt install -y bash-completion bsd-mailx curl dos2unix \
  git htop imagemagick inotify-tools libreoffice-common \
  lshw mc mini-httpd mlocate mupdf-tools net-tools samba \
  ssmtp sshfs tmux unoconv vim wakeonlan wget

apt autoremove -y

# configure samba
cat << EOF > /etc/samba/smb.conf
# edit to fit your settings
[global]
        workgroup = WORKGROUP
        server string = dsbd
        client signing = required
        disable spoolss = Yes
        load printers = No
        log file = /var/log/samba/log.%m
        max log size = 50
        printcap name = /dev/null
        idmap config * : backend = tdb
        hosts allow = 127. 10. 192.

[dsbd-flur]
        comment = DSBD
        path = /home/dsbd/dsbd@flur
        read only = No

[dsbd-lz]
        comment = DSBD
        path = /home/dsbd/dsbd@lz
        read only = No
EOF

# configure mini-httpd
sed -i /etc/mini-httpd.conf \
 -e 's/^host=.*/host=0.0.0.0/g' \
 -e 's/^charset=.*/charset=utf8/g'

sed -i /etc/default/mini-httpd \
 -e 's/^START=0/START=1/g' \

systemctl enable mini-httpd
systemctl enable smbd
systemctl enable nmbd

systemctl restart mini-httpd
systemctl restart smbd
systemctl restart nmbd

# use some temp directory for git
T=`mktemp -u -p /var/tmp/dsbd`
mkdir -p "$T"
pushd "$T"
git clone --depth=1 https://github.com/OpenDigitalSignage/ServerFiles

# copy dsbd files to /usr and /var
cp -r ServerFiles/var/lib/dsbd /var/lib/dsbd
cp -f ServerFiles/usr/sbin/dsbd /usr/sbin/dsbd
cp -f ServerFiles/usr/lib/systemd/system/dsbd@.service /usr/lib/systemd/system/dsbd@.service

popd
rm -rf "/var/tmp/dsbd"

# reload systemd
systemctl daemon-reload

# create dsbd user
useradd -g 100 -s /bin/false dsbd
mkdir -p /home/dsbd
chown dsbd /home/dsbd

# create as much services as you have TV groups
systemctl enable dsbd@flur
systemctl start dsbd@flur

systemctl enable dsbd@lz
systemctl start dsbd@lz

# last thing, add smb user with some password
# smbpasswd -a dsbd
