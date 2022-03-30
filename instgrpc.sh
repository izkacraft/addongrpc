wget -O portxtrgrpc "https://raw.githubusercontent.com/izhanworks/izvpn2/main/port/portxtrgrpc.sh"
chmod +x portxtrgrpc

wget -O port-grpc "https://raw.githubusercontent.com/izhanworks/izvpn2/main/port/port-grpc.sh"
chmod +x port-grpc 

wget -O menu-trgo "https://raw.githubusercontent.com/izhanworks/izvpn2/main/menu/menu-trgo.sh"
chmod +x menu-trgo

cat > /etc/systemd/system/vm-grpc.service << EOF
[Unit]
Description=XRay VMess GRPC Service
Documentation=https://speedtest.net https://github.com/XTLS/Xray-core
After=network.target nss-lookup.target
[Service]
User=root
NoNewPrivileges=true
ExecStart=/usr/local/bin/xray -config /etc/xray/vm-grpc.json
RestartPreventExitStatus=23
LimitNPROC=10000
LimitNOFILE=1000000
[Install]
WantedBy=multi-user.target
EOF

cat > /etc/systemd/system/vmess-grpc.service << EOF
[Unit]
Description=XRay VMess GRPC Service
Documentation=https://speedtest.net https://github.com/XTLS/Xray-core
After=network.target nss-lookup.target
[Service]
User=root
NoNewPrivileges=true
ExecStart=/usr/local/bin/xray -config /etc/xray/vmessgrpc.json
RestartPreventExitStatus=23
LimitNPROC=10000
LimitNOFILE=1000000
[Install]
WantedBy=multi-user.target
EOF

cat > /etc/systemd/system/vless-grpc.service << EOF
[Unit]
Description=XRay VMess GRPC Service
Documentation=https://speedtest.net https://github.com/XTLS/Xray-core
After=network.target nss-lookup.target
[Service]
User=root
NoNewPrivileges=true
ExecStart=/usr/local/bin/xray -config /etc/xray/vlessgrpc.json
RestartPreventExitStatus=23
LimitNPROC=10000
LimitNOFILE=1000000
[Install]
WantedBy=multi-user.target
EOF

cat > /etc/systemd/system/x-trgrpc.service << EOF
[Unit]
Description=XRay Trojan Grpc Service
Documentation=https://speedtest.net https://github.com/XTLS/Xray-core
After=network.target nss-lookup.target
[Service]
User=root
NoNewPrivileges=true
ExecStart=/usr/local/bin/xray -config /etc/xray/trojangrpc.json
RestartPreventExitStatus=23
LimitNPROC=10000
LimitNOFILE=1000000
[Install]
WantedBy=multi-user.target
EOF

service squid start


cat > /etc/xray/vmessgrpc.json << EOF
{
    "log": {
            "access": "/var/log/xray/access5.log",
        "error": "/var/log/xray/error.log",
        "loglevel": "info"
    },
    "inbounds": [
        {
            "port": 80,
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

cat > /etc/xray/vlessgrpc.json << EOF
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

cat > /etc/xray/trojangrpc.json << EOF
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

cat > /etc/xray/akuntrgrpc.conf << EOF
#xray-trojangrpc user
EOF

cat > /etc/xray/akun.conf << EOF
#xray-trojan user
EOF

iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 653 -j ACCEPT
iptables -I INPUT -m state --state NEW -m udp -p udp --dport 653 -j ACCEPT




iptables-save > /etc/iptables.up.rules
iptables-restore -t < /etc/iptables.up.rules
netfilter-persistent save
netfilter-persistent reload
systemctl daemon-reload
systemctl enable xr-vm-tls.service
systemctl start xr-vm-tls.service
systemctl enable xr-vm-ntls.service
systemctl start xr-vm-ntls.service
systemctl enable xr-vm-mk.service
systemctl start xr-vm-mk.service
systemctl enable xr-vl-tls.service
systemctl start xr-vl-tls.service
systemctl enable xr-vl-ntls.service
systemctl start xr-vl-ntls.service
systemctl restart xtls.service
systemctl enable xtls.service
systemctl enable x-tr
systemctl start x-tr 
systemctl enable vmess-grpc
systemctl restart vmess-grpc
systemctl enable vless-grpc
systemctl restart vless-grpc
systemctl enable x-trgrpc.service
systemctl start x-trgrpc.service

cd /usr/bin


wget -O addgrpc "https://raw.githubusercontent.com/izhanworks/izvpn2/main/add/addxvgrpc.sh"
wget -O addgrpc "https://raw.githubusercontent.com/izhanworks/izvpn2/main/add/addxvgrpc.sh"
wget -O delxvmess "https://raw.githubusercontent.com/izhanworks/izvpn2/main/del/delxv2ray.sh"



wget -O delgrpc "https://raw.githubusercontent.com/izhanworks/izvpn2/main/del/delgrpc.sh"




wget -O cekgrpc "https://raw.githubusercontent.com/izhanworks/izvpn2/main/cek/cekgrpc.sh"




wget -O renewgrpc "https://raw.githubusercontent.com/izhanworks/izvpn2/main/renew/renewgrpc.sh"



wget -O trialgrpc "https://raw.githubusercontent.com/izhanworks/izvpn2/main/trial/trialgrpc.sh"
wget -O addxtrgrpc "https://raw.githubusercontent.com/izhanworks/izvpn2/main/add/addxtrgrpc.sh"
wget -O delxtrgrpc "https://raw.githubusercontent.com/izhanworks/izvpn2/main/del/delxtrgrpc.sh"
wget -O cekxtrgrpc "https://raw.githubusercontent.com/izhanworks/izvpn2/main/cek/cekxtrgrpc.sh"
wget -O renewxtrgrpc "https://raw.githubusercontent.com/izhanworks/izvpn2/main/cek/renewxtrgrpc.sh"
chmod +x addxvmess
chmod +x addxvless
chmod +x addxtrojan
chmod +x addxtls
chmod +x addgrpc
chmod +x delxvless
chmod +x delxvmess
chmod +x delxtrojan
chmod +x delxtls
chmod +x delgrpc
chmod +x cekxvmess
chmod +x cekxvless
chmod +x cekxtrojan
chmod +x cekxtls
chmod +x cekgrpc
chmod +x renewxvmess
chmod +x renewxvless
chmod +x renewxtrojan
chmod +x renewxtls
chmod +x renewgrpc
chmod +x trialxvmess
chmod +x trialxvmess
chmod +x trialgrpc
chmod +x addxtrgrpc
chmod +x delxtrgrpc
chmod +x cekxtrgrpc
chmod +x renewxtrgrpc

