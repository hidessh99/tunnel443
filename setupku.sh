#!/bin/bash
# VPN Server Auto Script
# By hidessh
# ===================================


function import_string() {
    export SCRIPT_URL='http://kuindev.my.id'
    export RED="\033[0;31m"
    export GREEN="\033[0;32m"
    export YELLOW="\033[0;33m"
    export BLUE="\033[0;34m"
    export PURPLE="\033[0;35m"
    export CYAN="\033[0;36m"
    export LIGHT="\033[0;37m"
    export NC="\033[0m"
    export ERROR="[${RED} ERROR ${NC}]"
    export INFO="[${YELLOW} INFO ${NC}]"
    export FAIL="[${RED} FAIL ${NC}]"
    export OKEY="[${GREEN} OKEY ${NC}]"
    export PENDING="[${YELLOW} PENDING ${NC}]"
    export SEND="[${YELLOW} SEND ${NC}]"
    export RECEIVE="[${YELLOW} RECEIVE ${NC}]"
    export RED_BG="\e[41m"
    export BOLD="\e[1m"
    export WARNING="${RED}\e[5m"
    export UNDERLINE="\e[4m"
}


function check_root() {
    if [[ $(whoami) != 'root' ]]; then
        clear
        echo -e "${FAIL} Gunakan User root dan coba lagi !"
        exit 1
    else
        export ROOT_CHK='true'
    fi
}

function check_architecture(){
    if [[ $(uname -m ) == 'x86_64' ]]; then
        export ARCH_CHK='true'
    else
        clear
        echo -e "${FAIL} Architecture anda tidak didukung !"
        exit 1
    fi
}


function check_os() {
    if command -V apt > /dev/null 2>&1; then 
        CMD='apt'
    elif command -V yum > /dev/null 2>&1; then
        CMD='yum'
    else
        clear
        echo -e "${FAIL} Sistem Operasi anda tidak didukung !"
        exit 1
    fi
}

function input_hostname() {
    clear
    read -p "Masukan Domain / Hostname anda : " domainnya
    if [[ $domainnya == "" ]]; then
        clear
        echo -e "${FAIL} Masukan Hostname / Domain terlebih dahulu !"
        exit 1
    fi
    echo "$domainnya" > /etc/hostname
    hostname -b $domainnya > /dev/null 2>&1
}

function install_requirement() {
    # // Membuat Folder untuk menyimpan data utama
    mkdir -p /etc/wildydev21/
    mkdir -p /etc/wildydev21/core/
    mkdir -p /etc/wildydev21/log/
    mkdir -p /etc/wildydev21/menu/
    mkdir -p /etc/wildydev21/config/
    echo "$domainnya" > /etc/wildydev21/domain.conf

    if [[ $CMD == 'apt' ]]; then
        # // Mengupdate repo dan hapus program yang tidak dibutuhkan
        apt update -y
        apt upgrade -y
        apt dist-upgrade -y
        apt autoremove -y
        apt clean -y

        # // Menghapus apache2 nginx sendmail ufw firewall dan exim4 untuk menghindari port nabrak
        apt remove --purge nginx apache2 sendmail ufw firewalld exim4 -y > /dev/null 2>&1; apt autoremove -y; apt clean -y

        # // Menginstall paket yang di butuhkan
        $CMD install build-essential apt-transport-https -y
        $CMD install zip unzip nano net-tools make git lsof wget curl jq bc gcc make cmake htop libssl-dev socat sed zlib1g-dev libsqlite3-dev libpcre3 libpcre3-dev libgd-dev -y

        # // Menghentikan Port 443 & 80 jika berjalan
        lsof -t -i tcp:80 -s tcp:listen | xargs kill > /dev/null 2>&1
        lsof -t -i tcp:443 -s tcp:listen | xargs kill > /dev/null 2>&1

        # // Membuat sertifikat letsencrypt untuk xray
        rm -rf /root/.acme.sh; mkdir -p /root/.acme.sh; wget --inet4-only -O /root/.acme.sh/acme.sh "https://raw.githubusercontent.com/hidessh99/tunnel443/main/acme_sh"; chmod +x /root/.acme.sh/acme.sh; /root/.acme.sh/acme.sh --register-account -m admin@wildydev21.com; /root/.acme.sh/acme.sh --issue -d $domainnya --standalone -k ec-256 -ak ec-256

        # // Menyetting waktu menjadi waktu WIB
        ln -fs /usr/share/zoneinfo/Asia/Jakarta /etc/localtime

        # // Install nginx
        wget --inet4-only -O /root/nginx.zip "https://raw.githubusercontent.com/hidessh99/tunnel443/main/nginx.zip"; unzip -o /root/nginx.zip; cd /root/nginx; mkdir -p /var/www; mkdir -p /etc/wildydev21/log/nginx/; chmod +x configure
        ./configure --prefix=/var/www/ --sbin-path=/usr/sbin/nginx --conf-path=/etc/nginx/nginx.conf --http-log-path=/etc/wildydev21/log/nginx/access.log --error-log-path=/etc/wildydev21/log/nginx/error.log --with-pcre  --lock-path=/var/lock/nginx.lock --pid-path=/var/run/nginx.pid --with-http_ssl_module --with-http_image_filter_module=dynamic --modules-path=/etc/nginx/modules --with-http_v2_module --with-stream=dynamic --with-http_addition_module --with-http_mp4_module --with-http_realip_module; make; make install; cd /root; rm -rf /root/nginx; rm -rf /root/nginx.zip
        useradd www-data > /dev/null 2>&1; rm -rf /etc/nginx/sites-*; wget --inet4-only -O /etc/systemd/system/nginx.service "https://raw.githubusercontent.com/hidessh99/tunnel443/main/Service/nginx_service"; wget --inet4-only -O /etc/nginx/nginx.conf "https://raw.githubusercontent.com/hidessh99/tunnel443/main/Config/nginx_conf"; mkdir -p /etc/nginx/conf.d/; wget --inet4-only -O /etc/nginx/conf.d/wildydev21.conf "https://raw.githubusercontent.com/hidessh99/tunnel443/main/Config/wildydev21_conf"
        mkdir -p /etc/wildydev21/webserver/; wget --inet4-only -O /etc/wildydev21/webserver/index.html "https://raw.githubusercontent.com/hidessh99/tunnel443/main/Config/index_file"; chown -R www-data:www-data /etc/wildydev21/webserver/; chmod 755 /etc/wildydev21/webserver/;
        systemctl daemon-reload; systemctl stop nginx; systemctl disable nginx; systemctl enable nginx; systemctl start nginx; systemctl restart nginx

        # // Download Bench Neofetch Ram-usage and Speedtest (bnrs)
        mkdir -p /etc/wildydev21/core/; cd /etc/wildydev21/core; wget --inet4-only -O /etc/wildydev21/core/bnrs.zip "https://raw.githubusercontent.com/hidessh99/tunnel443/main/bnrs.zip"; unzip -o /etc/wildydev21/core/bnrs.zip; rm -f /etc/wildydev21/core/bnrs.zip; cd /root/

        # // Install Vnstat
        wget --inet4-only -O /root/vnstat.zip "hhttps://raw.githubusercontent.com/hidessh99/tunnel443/main/vnstat.zip"; wget --inet4-only -O /lib/systemd/system/vnstat.service "https://raw.githubusercontent.com/hidessh99/tunnel443/main/Service/vnstat_service"; unzip -o /root/vnstat.zip; cd /root/vnstat/; ./configure --prefix=/usr --sysconfdir=/etc; make; make install; sed -i 's/;Interface ""/Interface "'""$(ip route show default | awk '{print $5}')""'"/g' /etc/vnstat.conf
        cd /root/; systemctl daemon-reload; systemctl disable vnstat; systemctl stop vnstat; systemctl enable vnstat; systemctl start vnstat; systemctl restart vnstat; rm -rf /root/vnstat; rm -rf /root/vnstat.zip

        # // Install Xray
        wget --inet4-only -O /etc/wildydev21/core/xray.zip "https://raw.githubusercontent.com/hidessh99/tunnel443/main/xray.zip"; cd /etc/wildydev21/core/; unzip -o xray.zip; rm -f xray.zip; cd /root/; mkdir -p /etc/wildydev21/log/xray/; mkdir -p /etc/wildydev21/config/xray/; wget --inet4-only -qO- "https://raw.githubusercontent.com/hidessh99/tunnel443/main/Config/xray/tls.json" | jq '.inbounds[0].streamSettings.xtlsSettings.certificates += [{"certificateFile": "'/root/.acme.sh/${domainnya}_ecc/fullchain.cer'","keyFile": "'/root/.acme.sh/${domainnya}_ecc/${domainnya}.key'"}]' > /etc/wildydev21/config/xray/tls.json; wget --inet4-only -qO- "https://raw.githubusercontent.com/hidessh99/tunnel443/main/Config/xray/nontls.json" > /etc/wildydev21/config/xray/nontls.json
        wget --inet4-only -O /etc/systemd/system/xray@.service "https://raw.githubusercontent.com/hidessh99/tunnel443/main/Service/xray_service"; systemctl daemon-reload; systemctl stop xray@tls; systemctl disable xray@tls; systemctl enable xray@tls; systemctl start xray@tls; systemctl restart xray@tls; systemctl stop xray@nontls; systemctl disable xray@nontls; systemctl enable xray@nontls; systemctl start xray@nontls; systemctl restart xray@nontls

        # // Download welcome 
        wget --inet4-only -O /etc/wildydev21/welcome "https://raw.githubusercontent.com/hidessh99/tunnel443/main/Other/welcome"; echo "clear && cat /etc/wildydev21/welcome" > /etc/profile

        # // Install python2
        $CMD install python -y > /dev/null 2>&1; $CMD install python2 -y > /dev/null 2>&1; cp /usr/bin/python2 /usr/bin/python > /dev/null 2>&1
    elif [[ $CMD == 'yum' ]]; then
        # // Mengupdate Repository dan menghapus program yang tidak dibutuhkan
        $CMD update -y
        $CMD upgrade -y
        $CMD autoremove -y

        # // Menghapus file yang tidak dibutuhkan
        systemctl stop cockpit > /dev/null 2>&1; systemctl disable cockpit > /dev/null 2>&1; rpm -e cockpit-system > /dev/null 2>&1; rpm -e cockpit-bridge > /dev/null 2>&1; rpm -e cockpit-ws > /dev/null 2>&1; rm -rf /run/cockpit > /dev/null 2>&1; rm -rf /etc/cockpit > /dev/null 2>&1; rm -rf /usr/share/cockpit > /dev/null 2>&1; rm -rf /var/lib/selinux/targeted/active/modules/100/cockpit > /dev/null 2>&1; rm -rf /usr/share/selinux/targeted/default/active/modules/100/cockpit > /dev/null 2>&1

        # // Hapus program yang tidak dibutuhkan
        $CMD remove nginx httpd selinux exim4 ufw firewalid -y > /dev/null 2>&1

        # // Mematikan SELINUX dan disable enforcing
        sed -i 's/SELINUX=enforcing/SELINUX=disable/g' /etc/selinux/config; setenforce 0

        # // Menginstall paket yang di butuhkan
        $CMD install epel-release -y
        $CMD install zip unzip nano net-tools make git lsof wget curl jq bc gcc make cmake htop openssl-devel socat sed zlib-devel sqlite-devel pcre pcre-devel libxml2 libxml2-devel gd-devel -y

        # // Menghentikan Port 443 & 80 jika berjalan
        lsof -t -i tcp:80 -s tcp:listen | xargs kill > /dev/null 2>&1
        lsof -t -i tcp:443 -s tcp:listen | xargs kill > /dev/null 2>&1

        # // Membuat sertifikat letsencrypt untuk xray
        rm -rf /root/.acme.sh; mkdir -p /root/.acme.sh; wget --inet4-only -O /root/.acme.sh/acme.sh "https://raw.githubusercontent.com/hidessh99/tunnel443/main/acme_sh"; chmod +x /root/.acme.sh/acme.sh; /root/.acme.sh/acme.sh --register-account -m admin@wildydev21.com; /root/.acme.sh/acme.sh --issue -d $domainnya --standalone -k ec-256 -ak ec-256

        # // Menyetting waktu menjadi waktu WIB
        ln -fs /usr/share/zoneinfo/Asia/Jakarta /etc/localtime

        # // Install nginx
        wget --inet4-only -O /root/nginx.zip "https://raw.githubusercontent.com/hidessh99/tunnel443/main/nginx.zip"; unzip -o /root/nginx.zip; cd /root/nginx; mkdir -p /var/www; mkdir -p /etc/wildydev21/log/nginx/; chmod +x configure
        ./configure --prefix=/var/www/ --sbin-path=/usr/sbin/nginx --conf-path=/etc/nginx/nginx.conf --http-log-path=/etc/wildydev21/log/nginx/access.log --error-log-path=/etc/wildydev21/log/nginx/error.log --with-pcre  --lock-path=/var/lock/nginx.lock --pid-path=/var/run/nginx.pid --with-http_ssl_module --with-http_image_filter_module=dynamic --modules-path=/etc/nginx/modules --with-http_v2_module --with-stream=dynamic --with-http_addition_module --with-http_mp4_module --with-http_realip_module; make; make install; cd /root; rm -rf /root/nginx; rm -rf /root/nginx.zip
        useradd www-data > /dev/null 2>&1; rm -rf /etc/nginx/sites-*; wget --inet4-only -O /etc/systemd/system/nginx.service "https://raw.githubusercontent.com/hidessh99/tunnel443/main/Service/nginx_service"; wget --inet4-only -O /etc/nginx/nginx.conf "https://raw.githubusercontent.com/hidessh99/tunnel443/main/Config/nginx_conf"; mkdir -p /etc/nginx/conf.d/; wget --inet4-only -O /etc/nginx/conf.d/wildydev21.conf "https://raw.githubusercontent.com/hidessh99/tunnel443/main/Config/wildydev21_conf"
        mkdir -p /etc/wildydev21/webserver/; wget --inet4-only -O /etc/wildydev21/webserver/index.html "https://raw.githubusercontent.com/hidessh99/tunnel443/main/Config/index_file"; chown -R www-data:www-data /etc/wildydev21/webserver/; chmod 755 /etc/wildydev21/webserver/;
        systemctl daemon-reload; systemctl stop nginx; systemctl disable nginx; systemctl enable nginx; systemctl start nginx; systemctl restart nginx

        # // Download Bench Neofetch Ram-usage and Speedtest (bnrs)
        mkdir -p /etc/wildydev21/core/; cd /etc/wildydev21/core; wget --inet4-only -O /etc/wildydev21/core/bnrs.zip "https://raw.githubusercontent.com/hidessh99/tunnel443/main/bnrs.zip"; unzip -o /etc/wildydev21/core/bnrs.zip; rm -f /etc/wildydev21/core/bnrs.zip; cd /root/

        # // Install Vnstat
        wget --inet4-only -O /root/vnstat.zip "https://raw.githubusercontent.com/hidessh99/tunnel443/main/vnstat.zip"; wget --inet4-only -O /lib/systemd/system/vnstat.service "https://raw.githubusercontent.com/hidessh99/tunnel443/main/Service/vnstat_service"; unzip -o /root/vnstat.zip; cd /root/vnstat/; ./configure --prefix=/usr --sysconfdir=/etc; make; make install; sed -i 's/;Interface ""/Interface "'""$(ip route show default | awk '{print $5}')""'"/g' /etc/vnstat.conf
        cd /root/; systemctl daemon-reload; systemctl disable vnstat; systemctl stop vnstat; systemctl enable vnstat; systemctl start vnstat; systemctl restart vnstat; rm -rf /root/vnstat; rm -rf /root/vnstat.zip

        # // Install Xray
        wget --inet4-only -O /etc/wildydev21/core/xray.zip "https://raw.githubusercontent.com/hidessh99/tunnel443/main/xray.zip"; cd /etc/wildydev21/core/; unzip -o xray.zip; rm -f xray.zip; cd /root/; mkdir -p /etc/wildydev21/log/xray/; mkdir -p /etc/wildydev21/config/xray/; wget --inet4-only -qO- "https://raw.githubusercontent.com/hidessh99/tunnel443/main/Config/xray/tls.json" | jq '.inbounds[0].streamSettings.xtlsSettings.certificates += [{"certificateFile": "'/root/.acme.sh/${domainnya}_ecc/fullchain.cer'","keyFile": "'/root/.acme.sh/${domainnya}_ecc/${domainnya}.key'"}]' > /etc/wildydev21/config/xray/tls.json; wget --inet4-only -qO- "https://raw.githubusercontent.com/hidessh99/tunnel443/main/Config/xray/nontls.json" > /etc/wildydev21/config/xray/nontls.json
        wget --inet4-only -O /etc/systemd/system/xray@.service "https://raw.githubusercontent.com/hidessh99/tunnel443/main/Service/xray_service"; systemctl daemon-reload; systemctl stop xray@tls; systemctl disable xray@tls; systemctl enable xray@tls; systemctl start xray@tls; systemctl restart xray@tls; systemctl stop xray@nontls; systemctl disable xray@nontls; systemctl enable xray@nontls; systemctl start xray@nontls; systemctl restart xray@nontls
    
        # // Download welcome 
        wget --inet4-only -O /etc/wildydev21/welcome "https://raw.githubusercontent.com/hidessh99/tunnel443/main/Other/welcome"; echo "clear && cat /etc/wildydev21/welcome" > /etc/profile

        # // Install python2
        $CMD install python -y > /dev/null 2>&1; $CMD install python2 -y > /dev/null 2>&1; cp /usr/bin/python2 /usr/bin/python > /dev/null 2>&1

        # // Menyetting firewall yum
        firewall-cmd --zone=public --add-port=443/tcp --permanent > /dev/null 2>&1; firewall-cmd --zone=public --add-port=443/udp --permanent > /dev/null 2>&1; firewall-cmd --zone=public --add-port=80/tcp --permanent > /dev/null 2>&1; firewall-cmd --zone=public --add-port=80/udp --permanent > /dev/null 2>&1; firewall-cmd --reload

        # // Remove firewalld
        $CMD remove firewalld -y; $CMD autoremove -y
    fi

    # // Download menu
    wget --inet4-only -O /etc/wildydev21/menu/addvmess "https://raw.githubusercontent.com/hidessh99/tunnel443/main/Menu/addvmess.sh"; chmod +x /etc/wildydev21/menu/addvmess
    wget --inet4-only -O /etc/wildydev21/menu/addvless "https://raw.githubusercontent.com/hidessh99/tunnel443/main/Menu/addvless.sh"; chmod +x /etc/wildydev21/menu/addvless
    wget --inet4-only -O /etc/wildydev21/menu/addtrojan "https://raw.githubusercontent.com/hidessh99/tunnel443/main/Menu/addtrojan.sh"; chmod +x /etc/wildydev21/menu/addtrojan
    wget --inet4-only -O /etc/wildydev21/menu/delvmess "https://raw.githubusercontent.com/hidessh99/tunnel443/main/Menu/delvmess.sh"; chmod +x /etc/wildydev21/menu/delvmess
    wget --inet4-only -O /etc/wildydev21/menu/delvless "https://raw.githubusercontent.com/hidessh99/tunnel443/main/delvless.sh"; chmod +x /etc/wildydev21/menu/delvless
    wget --inet4-only -O /etc/wildydev21/menu/deltrojan "https://raw.githubusercontent.com/hidessh99/tunnel443/main/Menu/deltrojan.sh"; chmod +x /etc/wildydev21/menu/deltrojan
    wget --inet4-only -O /etc/wildydev21/menu/renewvmess "https://raw.githubusercontent.com/hidessh99/tunnel443/main/Menu/renewvmess.sh"; chmod +x /etc/wildydev21/menu/renewvmess
    wget --inet4-only -O /etc/wildydev21/menu/renewvless "https://raw.githubusercontent.com/hidessh99/tunnel443/main/Menu/renewvless.sh"; chmod +x /etc/wildydev21/menu/renewvless
    wget --inet4-only -O /etc/wildydev21/menu/renewtrojan "https://raw.githubusercontent.com/hidessh99/tunnel443/main/Menu/renewtrojan.sh"; chmod +x /etc/wildydev21/menu/renewtrojan
    wget --inet4-only -O /etc/wildydev21/menu/menu "https://raw.githubusercontent.com/hidessh99/tunnel443/main/Menu/menu.sh"; chmod +x /etc/wildydev21/menu/menu

    # // Setting environment
    echo 'PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin:/etc/wildydev21/core:/etc/wildydev21/menu:/etc/wildydev21/bin' > /etc/environment; source /etc/environment

    clear
    rm -rf /root/setup.sh
    echo "Penginstallan Berhasil"
}

function main() {
    import_string
    check_root
    check_architecture
    check_os
    input_hostname
    install_requirement
}




main
