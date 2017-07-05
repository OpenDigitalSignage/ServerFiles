#!/bin/sh

############################
# testet on CentOS 6.9 /TR #
############################

SERVERNAME="dsbserver"
USERNAME="dsbd"
USERPASS="dsbd"
IP_ADDR="192.168.100.32"
IP_OKAY="192.168.100.0/24"

# grab latest templates and daemon scripts
# yum install -y mc git
# mkdir -p /root/tmp
# cd /root/tmp || exit
# git clone --depth=1 https://github.com/OpenDigitalSignage/ServerFiles .

#########################################################################################################

# 1) install epel and ntpdate + nux desktop repo (ffmpeg etc)
yum install -y epel-release ntpdate
yum install -y http://li.nux.ro/download/nux/dextop/el6/x86_64/nux-dextop-release-0-2.el6.nux.noarch.rpm

# 2) install ssmtp
yum install -y ssmtp
alternatives --set mta /usr/sbin/sendmail.ssmtp
yum remove -y postfix

# 3) remove unneeded things and update all others
yum remove -y iscsi-initiator-utils selinux-policy lvm2
yum update -y

# 4) install mupdf (converts pdf to png...)
# you can also build it yourself, if you want...
yum install -y https://open-digital-signage.org/dl/mupdf-1.8-1.el6.x86_64.rpm

# 5) tmux, bash-completion, libreoffice, ...
yum install -y tmux bash-completion system-config-network-tui \
 setuptool vim sshfs wget hdparm smartmontools htop man man-pages \
 rsync dos2unix libreoffice httpd samba inotify-tools daemonize \
 ffmpeg ImageMagick

#########################################################################################################
# now some setup:
#########################################################################################################

# get some nice dotfiles
wget -O /root/.vimrc \
 https://raw.githubusercontent.com/mcmilk/dotfiles/master/.vimrc

wget -O /root/.tmux.conf \
 https://raw.githubusercontent.com/mcmilk/dotfiles/master/.tmux.conf

# configure ntpdate service
echo 0.pool.ntp.org >> /etc/ntp/step-tickers
chkconfig ntpdate on

# setup hostname @ /etc/hosts
echo -e "\n$IP_ADDR $SERVERNAME" >> /etc/hosts

# configure httpd
mv /etc/httpd/conf/httpd.conf /etc/httpd/conf/httpd.conf.default
cat /etc/httpd/conf/httpd.conf.default \
 | sed -e "s/#ServerName www.example.com:80/ServerName $SERVERNAME:80/g" \
 > /etc/httpd/conf/httpd.conf
chkconfig httpd on

# configure samba
cat << EOF > /etc/samba/smb.conf
[global]
    workgroup = WORKGROUP
    server string = $SERVERNAME
    log file = /var/log/samba/log.%m
    max log size = 50
    client signing = required
    load printers = No
    printcap name = /dev/null
    disable spoolss = Yes
    browseable = No
    hosts allow = 127., $IP_OKAY

[dsbd-sample]
    comment = DSBD
    path = /home/dsbd/dsbd-sample
    read only = No
    available = No

# you may and more if needed...
# /TR
EOF
chkconfig nmb on
chkconfig smb on

# create unix and samba user, default "dsbd" with password "dsbd"
# - you should change that! (or make this samba part of your domain)
rm -f /etc/skel/*
useradd $USERNAME -N
echo "$USERNAME:$USERPASS" | chpasswd
echo -e "$USERNAME\n$USERPASS\n" | smbpasswd -s -a $USERNAME
smbpasswd -e $USERNAME

# disable unwanted/unneeded services
chkconfig mdmonitor off
chkconfig iptables off
chkconfig ip6tables off

# move dsbd and dsbs to /usr/sbin:
cp ServerFiles/dsbd/dsbd /usr/sbin/dsbd
cp ServerFiles/dsbs/dsbs /usr/sbin/dsbs

#############################################################################
# - now you have to add the init scripts you want to /etc/rc.d/init.d
#
# 1) cp distrib/centos-6.x/dsbd-sample /etc/rc.d/init.d/dsbd-sample
# 2) chmod +x /etc/rc.d/init.d/dsbd-sample
# 3) chkconfig dsbd-sample on
#############################################################################
