cd /usr/bin

wget -O port-trgrpc "https://raw.githubusercontent.com/izhanworks/addongrpc/main/port-trgrpc.sh"
chmod +x port-trgrpc

wget -O port-grpc "https://raw.githubusercontent.com/izhanworks/addongrpc/main/port-grpc.sh"
chmod +x port-grpc 

wget -O menu-grpc "https://raw.githubusercontent.com/izhanworks/addongrpc/main/menu-grpc.sh"
chmod +x menu-grpc

service squid start


cat > /etc/rare/xray/conf/vmessgrpc.json << EOF
{
    "log": {
            "access": "/var/log/xray/access5.log",
        "error": "/var/log/xray/error.log",
        "loglevel": "info"
    },
    "inbounds": [
        {
            "port": 800,
            "protocol": "vmess",
            "settings": {
                "clients": [
                    {
                        "id": "${uuid}"
#vmessgrpc
                    }
                ],
                "decryption": "none"
            },
            "streamSettings": {
                "network": "gun",
                "security": "tls",
                "tlsSettings": {
                    "serverName": "${domain}",
                    "alpn": [
                        "h2"
                    ],
                    "certificates": [
                        {
                            "certificateFile": "/etc/xray/xray.crt",
                            "keyFile": "/etc/xray/xray.key"
                        }
                    ]
                },
                "grpcSettings": {
                    "serviceName": "GunService"
                }
            }
        }
    ],
    "outbounds": [
        {
            "protocol": "freedom",
            "tag": "direct"
        }
    ]
}
EOF

cat > /etc/rare/xray/conf/vlessgrpc.json << EOF
{
    "log": {
            "access": "/var/log/xray/access5.log",
        "error": "/var/log/xray/error.log",
        "loglevel": "info"
    },
    "inbounds": [
        {
            "port": 880,
            "protocol": "vless",
            "settings": {
                "clients": [
                    {
                        "id": "${uuid}"
#vlessgrpc
                    }
                ],
                "decryption": "none"
            },
            "streamSettings": {
                "network": "gun",
                "security": "tls",
                "tlsSettings": {
                    "serverName": "${domain}",
                    "alpn": [
                        "h2"
                    ],
                    "certificates": [
                        {
                            "certificateFile": "/etc/xray/xray.crt",
                            "keyFile": "/etc/xray/xray.key"
                        }
                    ]
                },
                "grpcSettings": {
                    "serviceName": "GunService"
                }
            }
        }
    ],
    "outbounds": [
        {
            "protocol": "freedom",
            "tag": "direct"
        }
    ]
}
EOF

cat > /etc/rare/xray/conf/trojangrpc.json << EOF
{
    "log": {
            "access": "/var/log/xray/access5.log",
        "error": "/var/log/xray/error.log",
        "loglevel": "info"
    },
    "inbounds": [
        {
            "port": 653,
            "protocol": "trojan",
            "settings": {
                "clients": [
                    {
                        "password": "${uuid}"
#xtrgrpc
                    }
                ],
                "decryption": "none"
            },
            "streamSettings": {
                "network": "gun",
                "security": "tls",
                "tlsSettings": {
                    "serverName": "$domain",
                    "alpn": [
                        "h2"
                    ],
                    "certificates": [
                        {
                            "certificateFile": "/etc/xray/xray.crt",
                            "keyFile": "/etc/xray/xray.key"
                        }
                    ]
                },
                "grpcSettings": {
                    "serviceName": "GunService"
                }
            }
        }
    ],
    "outbounds": [
        {
            "protocol": "freedom",
            "tag": "direct"
        }
    ]
}
EOF

cat > /etc/rare/xray/conf/akuntrgrpc.conf << EOF
#xray-trojangrpc user
EOF

iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 800 -j ACCEPT
iptables -I INPUT -m state --state NEW -m udp -p udp --dport 800 -j ACCEPT
iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 880 -j ACCEPT
iptables -I INPUT -m state --state NEW -m udp -p udp --dport 880 -j ACCEPT
iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 653 -j ACCEPT
iptables -I INPUT -m state --state NEW -m udp -p udp --dport 653 -j ACCEPT


iptables-save > /etc/iptables.up.rules
iptables-restore -t < /etc/iptables.up.rules
netfilter-persistent save
netfilter-persistent reload
systemctl daemon-reload
systemctl restart xray.service

wget -O addgrpc "https://raw.githubusercontent.com/izhanworks/addongrpc/main/addgrpc.sh"
wget -O delgrpc "https://raw.githubusercontent.com/izhanworks/addongrpc/main/delgrpc.sh"
wget -O cekgrpc "https://raw.githubusercontent.com/izhanworks/addongrpc/main/cekgrpc.sh"
wget -O renewgrpc "https://raw.githubusercontent.com/izhanworks/addongrpc/main/renewgrpc.sh"

wget -O addtrgrpc "https://raw.githubusercontent.com/izhanworks/addongrpc/main/addtrgrpc.sh"
wget -O deltrgrpc "https://raw.githubusercontent.com/izhanworks/addongrpc/main/deltrgrpc.sh"
wget -O cektrgrpc "https://raw.githubusercontent.com/izhanworks/addongrpc/main/cektrgrpc.sh"
wget -O renewtrgrpc "https://raw.githubusercontent.com/izhanworks/addongrpc/main/renewtrgrpc.sh"

chmod +x addgrpc
chmod +x delgrpc
chmod +x cekgrpc
chmod +x renewgrpc

chmod +x addtrgrpc
chmod +x deltrgrpc
chmod +x cektrgrpc
chmod +x renewtrgrpc

cd
rm /root/instgrpc.sh
