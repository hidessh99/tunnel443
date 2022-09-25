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

# // Start
CLIENT_001=$(grep -c -E "^Vmess " "/etc/wildydev21/xray-client.conf" );
echo "    ==================================================";
echo "               LIST VMESS CLIENT ON THIS VPS";
echo "    ==================================================";
grep -e "^Vmess " "/etc/wildydev21/xray-client.conf" | cut -d ' ' -f 2-3 | nl -s ') ';
	until [[ ${CLIENT_002} -ge 1 && ${CLIENT_002} -le ${CLIENT_001} ]]; do
		if [[ ${CLIENT_002} == '1' ]]; then
                echo "    ==================================================";
			read -rp "    Please Input an Client Number (1-${CLIENT_001}) : " CLIENT_002;
		else
                echo "    ==================================================";
			read -rp "    Please Input an Client Number (1-${CLIENT_001}) : " CLIENT_002;
		fi
	done

# // String For Username && Expired Date
client=$(grep "^Vmess " "/etc/wildydev21/xray-client.conf" | cut -d ' ' -f 2 | sed -n "${CLIENT_002}"p);
expired=$(grep "^Vmess " "/etc/wildydev21/xray-client.conf" | cut -d ' ' -f 3 | sed -n "${CLIENT_002}"p);
uuidnta=$(grep "^Vmess " "/etc/wildydev21/xray-client.conf" | cut -d ' ' -f 4 | sed -n "${CLIENT_002}"p);


# // Extending Days
clear;
read -p "Expired  : " Jumlah_Hari;
if [[ $Jumlah_Hari == "" ]]; then
    clear;
    echo -e "${FAIL} Mohon Masukan Jumlah Hari perpanjangan !";
    exit 1;
fi

# // Date Configuration
now=$(date +%Y-%m-%d);
d1=$(date -d "$expired" +%s);
d2=$(date -d "$now" +%s);
exp2=$(( (d1 - d2) / 86400 ));
exp3=$(($exp2 + $Jumlah_Hari));
exp4=`date -d "$exp3 days" +"%Y-%m-%d"`;

# // Input To System Configuration
sed -i "/\b$client\b/d" /etc/wildydev21/xray-client.conf
echo -e "Vmess $client $exp4 $uuidnta" >> /etc/wildydev21/xray-client.conf

# // Clear
clear;

# // Successfull
echo -e "${OKEY} User ( ${YELLOW}${client}${NC} ) Renewed Then Expired On ( ${YELLOW}$exp4${NC} )";