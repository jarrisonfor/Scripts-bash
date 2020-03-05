#!/bin/bash
if ! [[ $(id -u) = 0 ]]; then
echo "se necesita ejecutar como root"
exit 1
else
echo "Se necesita poner la tarjetas de red de la siguiente manera: 1º tarjeta en NAT, 2º tarjeta en red interna"
echo "Cuando termine el script se apagara la maquina, configuralo cuando se haga si no lo has hecho ya"
sleep 20
sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/' /etc/sysctl.conf
echo "#!/bin/bash
iptables -A FORWARD -j ACCEPT
iptables -t nat -A POSTROUTING -s 192.168.2.0/24 -o enp0s3 -j MASQUERADE
" > /etc/init.d/nat.sh

chmod +x /etc/init.d/nat.sh

echo "[Unit]
 Description=enable SNAT
 ConditionPathExists=/etc/init.d/nat.sh

[Service]
 Type=forking
 ExecStart=/etc/init.d/nat.sh
 TimeoutSec=0
 StandardOutput=tty
 RemainAfterExit=yes
 SysVStartPriority=99

[Install]
 WantedBy=multi-user.target
" > /etc/systemd/system/nat.service

echo "network:
    ethernets:
        enp0s3:
            dhcp4: true
        enp0s8:
            addresses: [192.168.2.1/24]
            dhcp4: false
    version: 2
" > /etc/netplan/50-cloud-init.yaml

netplan apply

systemctl enable nat.service
systemctl start nat.service
shutdown now
fi
