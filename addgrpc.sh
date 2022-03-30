#!/bin/bash
#########################

MYIP=$(wget -qO- ipinfo.io/ip);
echo "Checking VPS"
clear
echo -e "================================="
echo -e "         XRAY GRPC               "
echo -e "================================="

domain=$(cat /root/domain)
tls=$(cat /etc/rare/xray/conf/vmessgrpc.json | grep port | awk '{print $2}' | sed 's/,//g')
vl=$(cat /etc/rare/xray/conf/vlessgrpc.json | grep port | awk '{print $2}' | sed 's/,//g')
until [[ $user =~ ^[a-zA-Z0-9_]+$ && ${CLIENT_EXISTS} == '0' ]]; do
		read -rp "User: " -e user
		CLIENT_EXISTS=$(grep -w $user /etc/rare/xray/conf/vmessgrpc.json | wc -l)

		if [[ ${CLIENT_EXISTS} == '1' ]]; then
			echo ""
			echo "A client with the specified name was already created, please choose another name."
			exit 1
		fi
	done
uuid=$(cat /proc/sys/kernel/random/uuid)
read -p "Expired (days): " masaaktif
read -p "SNI (bug) : " sni
read -p "ADDRESS (BUG) : " sub
dom=$sub.$domain
exp=`date -d "$masaaktif days" +"%Y-%m-%d"`
sed -i '/#vmessgrpc$/a\### '"$user $exp"'\
},{"id": "'""$uuid""'","alterId": '"0"',"email": "'""$user""'"' /etc/rare/xray/conf/vmessgrpc.json
sed -i '/#vlessgrpc$/a\### '"$user $exp"'\
},{"id": "'""$uuid""'","email": "'""$user""'"' /etc/rare/xray/conf/vlessgrpc.json
cat > /etc/rare/xray/conf/$user-tls.json << EOF
      {
      "v": "0",
      "ps": "${user}",
      "add": "${dom}",
      "port": "${tls}",
      "id": "${uuid}",
      "aid": "0",
      "net": "grpc",
      "path": "GunService",
      "type": "none",
      "host": "${sni}",
      "tls": "tls"
}
EOF
vmess_base641=$( base64 -w 0 <<< $vmess_json1)
vmesslink1="vmess://$(base64 -w 0 /etc/rare/xray/conf/$user-tls.json)"
vlesslink1="vless://${uuid}@${dom}:${vl}?mode=gun&security=tls&encryption=none&type=grpc&serviceName=GunService&sni=$sni#$user"
systemctl restart xray.service
service cron restart
echo ""
echo -e "================================="
echo -e "            XRAY GRPC            " 
echo -e "================================="
echo -e "Remarks           : ${user}"
echo -e "Domain            : ${domain}"
echo -e "Port VMess        : ${tls}"
echo -e "Port VLess        : $vl"
echo -e "ID                : ${uuid}"
echo -e "Alter ID          : 0"
echo -e "Mode              : Gun"
echo -e "Security          : TLS"
echo -e "Type              : grpc"
echo -e "Service Name      : GunService"
echo -e "SNI               : $sni"
echo -e "================================="
echo -e "Link VMess GRPC  : "
echo -e "${vmesslink1}"
echo -e "================================="
echo -e "Link VLess GRPC  : "
echo -e "${vlesslink1}"
echo -e "================================="
echo -e "Expired On     : $exp"
echo -e "=================================" 
echo ""
echo -e "[1]  Tambah User Grpc"
echo -e "[2]  Grpc Menu"
echo -e "[3]  Menu Utama" 
echo -e "[x]  Keluar" 
echo -e "================================="
read -p "Pilihan :" menu
case $menu in
1) clear ; addgrpc ;;
2) clear ; menu-grpc ;;
3) clear ; menu ;;
x) exit ;;
*) echo  "Pilihan Salah" ;;
esac
