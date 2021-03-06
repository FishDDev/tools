#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

##by:      Fish
##mailto:  fishdev@qq.com

#set color
red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
plain='\033[0m'

#create lock dir
mkdir -p /etc/fish
#set log url
rclog="/etc/fish/re.log"
#set git url
giturl="https://raw.githubusercontent.com/FishDDev/tools/Privated/shadowsocks-tools"
#set serverspeeder bin url
serverspeeder_init="/serverspeeder/bin/serverSpeeder.sh"
#set shadowsocks init url
ss_init[0]="/etc/init.d/shadowsocks"
ss_init[1]="/etc/init.d/shadowsocks-python"
ss_init[2]="/etc/init.d/shadowsocks-r"
ss_init[3]="/etc/init.d/shadowsocks-go"
ss_init[4]="/etc/init.d/shadowsocks-libev"
i=0
for init in ${ss_init[@]}; do
    if [ -f ${init} ]; then
    export ss_init=${init}
    fi
done

check_root(){
    if [[ $EUID -ne 0 ]]; then
    echo -e "${red}Error:${plain} This script must be run as root!"
       exit 1
    fi
}

disable_selinux() {
    if [ -s /etc/selinux/config ] && grep 'SELINUX=enforcing' /etc/selinux/config; then
        sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
        setenforce 0
    fi
}

set_timezone()
{
    if ! grep -q "Asia/Shanghai" /etc/timezone; then
    echo "Asia/Shanghai" >/etc/timezone
#create .timezone
    touch /etc/fish/.timezone
    fi
}

check_dependencies()
{
   if ! [ -f /etc/fish/.dependencies ] ; then
   yum clean all &&
   yum update -y && yum upgrade -y &&
   #yum dependencies
   yum install -y unzip gzip openssl openssl-devel gcc swig python python-devel python-setuptools libtool libevent xmlto autoconf automake make curl curl-devel zlib-devel perl perl-devel cpio expat-devel gettext-devel asciidoc &&
#create .dependencies
   touch /etc/fish/.dependencies
#yum install -y autoconf automake libtool gcc swig make perl cpio xmlto asciidoc libpcre3 libpcre3-dev zlib1g-dev unzip gzip openssl openssl-devel python python-devel python-setuptools libevent curl curl-devel zlib-devel perl-devel expat-devel gettext-devel m2crypto libnet libpcap libnet-devel libpcap-devel net-tools python-pip redhat-lsb build-essential python-dev python-m2crypto libssl-dev
#pip install --upgrade -I pip
#pip install -I greenlet gevent m2crypto
   fi
}

check_shadowsocks()
{
    if [ -f ${ss_init} ] ; then
        echo -e "${yellow}Shadowsocks installed${plain}"
    else
        rm -rf ./shadowsocks-install.*
        wget --no-check-certificate ${giturl}/shadowsocks-install.sh >>${rclog} 2>&1 &&
        ( chmod +x shadowsocks-install.sh ;
        echo -e "${green}done: Shadowsocks installation scripts${plain}" ) ||
        echo -e "${red}failed: Shadowsocks installation scripts${plain}"
    fi
}

check_serverspeeder()
{
    if [ -f ${serverspeeder_init} ] ; then
        echo -e "${yellow}serverSpeeder installed${plain}"
    else
        rm -rf ./serverspeeder.*
        wget --no-check-certificate ${giturl}/serverspeeder.sh >>${rclog} 2>&1  &&
        ( chmod +x serverspeeder.sh ;
        echo -e "${green}done: serverSpeeder installation scripts${plain}" ) ||
        echo -e "${red}failed: serverSpeeder installation scripts${plain}"
    fi
}

optimized_shadowsocks()
{
    if ! grep -q "* soft nofile" /etc/security/limits.conf; then
        echo -e "* soft nofile 51200\n* hard nofile 51200" >> /etc/security/limits.conf
#create .optimized
    touch /etc/fish/.optimized
    fi
}

restart_service()
{
    if [ -f ${ss_init} ] ; then
        echo -e "${red}Restart Service: Shadowsocks${plain}"
        ${ss_init} restart
    fi
    
    if [ -f ${serverspeeder_init} ] ; then
        echo -e "${red}Restart Service: serverSpeeder${plain}"
        ${serverspeeder_init} restart
    fi
}


#run shell
check_root
rm -rf ${rclog}
disable_selinux
#set_timezone
#check_dependencies
check_shadowsocks
#check_serverspeeder
#optimized_shadowsocks
restart_service