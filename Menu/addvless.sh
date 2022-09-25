#!/bin/bash

function import_data() {
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

import_data
IPNYA=$( wget --inet4-only -qO- https://ipinfo.io/ip )
ISPNYA=$( wget --inet4-only -qO- https://ipinfo.io/org | cut -d " " -f 2-100 )
clear

read -p "Username : " Username
Username="$(echo ${Username} | sed 's/ //g' | tr -d '\r' | tr -d '\r\n' )"

# // Validate Input
if [[ $Username == "" ]]; then
    clear;
    echo -e "${FAIL} Silakan Masukan Username terlebih dahulu !"
    exit 1
fi

touch /etc/wildydev21/xray-client.conf

# // Checking User already on vps or no
if [[ "$( cat /etc/wildydev21/xray-client.conf | grep -w ${Username})" == "" ]]; then
    Do=Nothing
else
    clear
    echo -e "${FAIL} User [ ${Username} ] sudah ada !"
    exit 1
fi

# // Expired Date
read -p "Expired  : " Jumlah_Hari
exp=`date -d "$Jumlah_Hari days" +"%Y-%m-%d"`
hariini=`date -d "0 days" +"%Y-%m-%d"`

# // Get UUID
uuidnya=$( xray uuid )

# // Generate New UUID & Domain
domain=$( cat /etc/wildydev21/domain.conf )

# // Force create folder for fixing account wasted
mkdir -p /etc/wildydev21/xray-cache/
mkdir -p /etc/wildydev21/cache/

# // Getting Vmess port using grep from config
tls_port=$( cat /etc/wildydev21/config/xray/tls.json | grep -w port | awk '{print $2}' | head -n1 | sed 's/,//g' | tr '\n' ' ' | tr -d '\r' | tr -d '\r\n' | sed 's/ //g' )
nontls_port=$( cat /etc/wildydev21/config/xray/nontls.json | grep -w port | awk '{print $2}' | head -n1 | sed 's/,//g' | tr '\n' ' ' | tr -d '\r' | tr -d '\r\n' | sed 's/ //g' )

# // Input Your Data to server
printf "y\n" | cp /etc/wildydev21/config/xray/tls.json /etc/wildydev21/xray-cache/cache-nya.json
cat /etc/wildydev21/xray-cache/cache-nya.json | jq '.inbounds[3].settings.clients += [{"id": "'${uuidnya}'","email": "'${Username}'"}]' > /etc/wildydev21/xray-cache/cache-nya2.json
cat /etc/wildydev21/xray-cache/cache-nya2.json | jq '.inbounds[6].settings.clients += [{"id": "'${uuidnya}'","email": "'${Username}'"}]' > /etc/wildydev21/config/xray/tls.json
printf "y\n" | cp /etc/wildydev21/config/xray/nontls.json /etc/wildydev21/xray-cache/cache2-nya.json
cat /etc/wildydev21/xray-cache/cache2-nya.json | jq '.inbounds[1].settings.clients += [{"id": "'${uuidnya}'","email": "'${Username}'"}]' > /etc/wildydev21/config/xray/nontls.json
echo -e "Vless $Username $exp $uuidnya" >> /etc/wildydev21/xray-client.conf

# // Vless Link
vless_nontls="vless://${uuidnya}@${domain}:${nontls_port}?path=%2Fvless&security=none&encryption=none&type=ws#${Username}";
vless_tls="vless://${uuidnya}@${domain}:${tls_port}?path=%2Fvless&security=tls&encryption=none&type=ws#${Username}";
vless_grpc="vless://${uuidnya}@${domain}:${tls_port}?mode=gun&security=tls&encryption=none&type=grpc&serviceName=Vless-GRPC#${Username}";

# // Restarting XRay Service
systemctl restart xray@tls
systemctl restart xray@nontls

# // Success
clear
echo -e "Vless Account Details"
echo -e "==============================="
echo -e " ISP         = ${ISPNYA}"
echo -e " Remarks     = ${Username}"
echo -e " IP          = ${IPNYA}"
echo -e " Address     = ${domain}"
echo -e " Port TLS    = ${tls_port}"
echo -e " Port NonTLS = ${nontls_port}"
echo -e " UUID        = ${uuidnya}"
echo -e "==============================="
echo -e " GRPC VLESS CONFIG LINK"
echo -e ' ```'${vless_grpc}'```'
echo -e "==============================="
echo -e " WS TLS VLESS CONFIG LINK"
echo -e ' ```'${vless_tls}'```'
echo -e "==============================="
echo -e " WS NTLS VLESS CONFIG LINK"
echo -e ' ```'${vless_nontls}'```'
echo -e "==============================="
echo -e " Created     = ${hariini}"
echo -e " Expired     = ${exp}"
echo -e "==============================="