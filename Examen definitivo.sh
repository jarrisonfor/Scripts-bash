#!/bin/bash
function cliente {

apt update
apt install ldap-auth-client nscd -y
auth-client-config -t nss -p lac_ldap
apt install libpam-ldapd -y
pam-auth-update

apt install nfs-common rpcbind -y
mkdir /home/servidor/
chmod 777 /home/servidor
chown nobody:nogroup /home/servidor
mkdir /moving
chmod 777 /moving
chown nobody:nogroup /moving
echo "192.168.10.1:/srv/compartida /home/servidor   nfs defaults 0 0" >> /etc/fstab
echo "192.168.10.1:/srv/profiles /moving    nfs defaults 0 0" >> /etc/fstab
reboot
}

function primero {
echo "" >> /etc/network/interfaces
echo "auto enp0s8" >> /etc/network/interfaces
echo "iface enp0s8 inet static" >> /etc/network/interfaces
echo "address 192.168.10.1" >> /etc/network/interfaces
echo "netmask 24" >> /etc/network/interfaces
ifup enp0s8
nano /etc/sysctl.conf
echo "iptables -A FORWARD -j ACCEPT" >> /etc/init.d/nat.sh
echo "iptables -t nat -A POSTROUTING -s 192.168.10.0/24 -o enp0s3 -j MASQUERADE" >> /etc/init.d/nat.sh
sudo chmod +x /etc/init.d/nat.sh
echo "#!/bin/sh -e" > /etc/rc.local
echo "/etc/init.d/nat.sh" >> /etc/rc.local
echo "exit 0" >> /etc/rc.local
echo "server" > /etc/hostname
echo "127.0.0.1       localhost" > /etc/hosts
echo "192.168.10.1       server.examen.sor server" >> /etc/hosts
echo ""
echo "::1     localhost ip6-localhost ip6-loopback" >> /etc/hosts
echo "ff02::1 ip6-allnodes" >> /etc/hosts
echo "ff02::2 ip6-allrouters" >> /etc/hosts
hostname examen
apt update
apt install slapd ldap-utils nfs-common nfs-kernel-server -y
sudo dpkg-reconfigure slapd

clear
echo "dime tu primer apellido"
read apellido1

clear
echo "dime tu segundo apellido"
read apellido2

echo "dn: ou=$apellido1,dc=examen,dc=sor" > unidades.ldif
echo "objectClass: organizationalUnit" >> unidades.ldif
echo "ou: $apellido1" >> unidades.ldif
echo "" >> unidades.ldif
echo "dn: ou=$apellido2,dc=examen,dc=sor" >> unidades.ldif
echo "objectClass: organizationalUnit" >> unidades.ldif
echo "ou: $apellido2" >> unidades.ldif


echo "dn: cn=amigos,ou=$apellido1,dc=examen,dc=sor" > grupos.ldif
echo "objectClass: posixGroup" >> grupos.ldif
echo "cn: amigos" >> grupos.ldif
echo "gidNumber: 10000" >> grupos.ldif
echo "" >> grupos.ldif
echo "dn: cn=abuelos,ou=$apellido1,dc=examen,dc=sor" >> grupos.ldif
echo "objectClass: posixGroup" >> grupos.ldif
echo "cn: abuelos" >> grupos.ldif
echo "gidNumber: 10001" >> grupos.ldif

clear
echo "dime nombre primer amigo"
read amigo
clear
echo "dime nombre segundo amigo"
read amigo2
clear
echo "dime primer abuelo"
read abuelo
clear
echo "dime segundo abuelo"
read abuelo2


echo "dn: uid=$amigo,dc=examen,dc=sor" >> usuarios.ldif
echo "objectClass: inetOrgPerson" >> usuarios.ldif
echo "objectClass: posixAccount" >> usuarios.ldif
echo "objectClass: shadowAccount" >> usuarios.ldif
echo "uid: $amigo" >> usuarios.ldif
echo "sn: amigo1" >> usuarios.ldif
echo "cn: $amigo amigo1" >> usuarios.ldif
echo "uidNumber: 2000" >> usuarios.ldif
echo "gidNumber: 10000" >> usuarios.ldif
echo "userPassword: smr1234" >> usuarios.ldif
echo "homeDirectory: /home/$amigo" >> usuarios.ldif
echo "" >> usuarios.ldif

echo "dn: uid=$amigo2,dc=examen,dc=sor" >> usuarios.ldif
echo "objectClass: inetOrgPerson" >> usuarios.ldif
echo "objectClass: posixAccount" >> usuarios.ldif
echo "objectClass: shadowAccount" >> usuarios.ldif
echo "uid: $amigo2" >> usuarios.ldif
echo "sn: amigo2" >> usuarios.ldif
echo "cn: $amigo2 amigo2" >> usuarios.ldif
echo "uidNumber: 2001" >> usuarios.ldif
echo "gidNumber: 10000" >> usuarios.ldif
echo "userPassword: smr1234" >> usuarios.ldif
echo "homeDirectory: /moving/$amigo2" >> usuarios.ldif
echo "" >> usuarios.ldif

echo "dn: uid=$abuelo,dc=examen,dc=sor" >> usuarios.ldif
echo "objectClass: inetOrgPerson" >> usuarios.ldif
echo "objectClass: posixAccount" >> usuarios.ldif
echo "objectClass: shadowAccount" >> usuarios.ldif
echo "uid: $abuelo" >> usuarios.ldif
echo "sn: abuelo1" >> usuarios.ldif
echo "cn: $abuelo abuelo1" >> usuarios.ldif
echo "uidNumber: 2002" >> usuarios.ldif
echo "gidNumber: 10001" >> usuarios.ldif
echo "userPassword: smr1234" >> usuarios.ldif
echo "homeDirectory: /home/$abuelo" >> usuarios.ldif
echo "" >> usuarios.ldif

echo "dn: uid=$abuelo2,dc=examen,dc=sor" >> usuarios.ldif
echo "objectClass: inetOrgPerson" >> usuarios.ldif
echo "objectClass: posixAccount" >> usuarios.ldif
echo "objectClass: shadowAccount" >> usuarios.ldif
echo "uid: $abuelo2" >> usuarios.ldif
echo "sn: abuelo2" >> usuarios.ldif
echo "cn: $abuelo2 abuelo2" >> usuarios.ldif
echo "uidNumber: 2003" >> usuarios.ldif
echo "gidNumber: 10001" >> usuarios.ldif
echo "userPassword: smr1234" >> usuarios.ldif
echo "homeDirectory: /moving/$abuelo2" >> usuarios.ldif
echo "" >> usuarios.ldif


ldapadd -x -D cn=admin,dc=examen,dc=sor -W -f unidades.ldif
ldapadd -x -D cn=admin,dc=examen,dc=sor -W -f grupos.ldif
ldapadd -x -D cn=admin,dc=examen,dc=sor -W -f usuarios.ldif
reboot
}

function segundo {
apt install ldap-auth-client nscd -y
auth-client-config -t nss -p lac_ldap
apt install libpam-ldapd -y
pam-auth-update
reboot

}

function tercero {
mkdir -p /srv/compartida/lectura
mkdir -p /srv/compartida/escritura
chmod -R 777 /srv/compartida
chown -R nobody:nogroup /srv/compartida
chmod 555 /srv/compartida/lectura
echo "/srv/compartida *(rw,sync,no_root_squash,no_subtree_check)" >> /etc/exports
exportfs -a
service nfs-kernel-server restart
}

function cuarto {
mkdir /srv/profiles
chmod 777 /srv/profiles
chown nobody:nogroup /srv/profiles
echo "/srv/profiles     *(rw,sync,no_root_squash,no_subtree_check)" >> /etc/exports
exportfs -a
}

function quinto {
clear
echo "dime tu nombre"
read nombre
useradd $nombre

echo "dn: cn=yeray,dc=examen,dc=sor" > yo.ldif
echo "objectClass: posixGroup" >> yo.ldif
echo "cn: amigos" >> yo.ldif
echo "gidNumber: 10002" >> yo.ldif

echo "" >> yo.ldif
echo "dn: uid=$nombre,dc=examen,dc=sor" >> yo.ldif
echo "objectClass: inetOrgPerson" >> yo.ldif
echo "objectClass: posixAccount" >> yo.ldif
echo "objectClass: shadowAccount" >> yo.ldif
echo "uid: $nombre" >> yo.ldif
echo "sn: yo" >> yo.ldif
echo "cn: $nombre yo" >> yo.ldif
echo "uidNumber: 2005" >> yo.ldif
echo "gidNumber: 10002" >> yo.ldif
echo "userPassword: smr1234" >> yo.ldif
echo "homeDirectory: /home/$nombre" >> yo.ldif

ldapadd -x -D cn=admin,dc=examen,dc=sor -W -f yo.ldif


echo "dn: uid=$nombre,dc=examen,dc=sor" > cambios.ldif
echo "changetype: modify" >> cambios.ldif
echo "replace: gidNumber" >> cambios.ldif
echo "gidNumber: 10000" >> cambios.ldif
echo "" >> cambios.ldif
echo "dn: uid=$nombre,dc=examen,dc=sor" >> cambios.ldif
echo "changetype: modify" >> cambios.ldif
echo "replace: homeDirectory" >> cambios.ldif
echo "homeDirectory: /moving/$nombre" >> cambios.ldif

ldapmodify -x -D cn=admin,dc=examen,dc=sor -W -f cambios.ldif

}

function sexto {
apt install quota quotatool
echo "tienes que borrar lo de errors=remount-ro y cambiarlo por defaults,usrquota,grpquota"
echo ""
read -p "Pulsa enter para continuar"
nano /etc/fstab
quotacheck -cgu /
quotacheck -fm /
clear
echo "dime tu primer usuario local (el primero)"
read local1
clear
echo "dime tu segundo usuario local (el tercer usuario)"
read local2
edquota -u $local1
edquota -u $local2
reboot
}

function septimo {
tasksel
sh -c 'echo "deb http://download.webmin.com/download/repository sarge contrib" > /etc/apt/sources.list.d/webmin.list'
wget -qO - http://www.webmin.com/jcameron-key.asc | sudo apt-key add -
apt-get install webmin apache2 apache2-utils -y
clear
}

function noveno {
apt install cups-pdf apache2 apache2-utils -y
nano /etc/cups/cupsd.conf
service cups restart
service cups-browsed restart
echo "Entra en un navegador a la direccion https://192.168.10.1:631"
echo "los archivos imprimidos aparecen en el usuario correspondiente en el servidor y si no existe en /var/spool/cups..."
}

function decimo {
echo "#!/bin/bash" >> smb.sh
echo "slapcat | grep 'uid: ' | cut -d' ' -f2 > tmp.txt" >> smb.sh
echo "" >> smb.sh
echo "while read linea" >> smb.sh
echo "do" >> smb.sh
echo "        echo '$linea'" >> smb.sh
echo "        useradd $linea" >> smb.sh
echo "        (echo 'smr1234'; echo 'smr1234') | smbpasswd -a -s $linea" >> smb.sh
echo "done < tmp.txt" >> smb.sh
chmod 777 smb.sh
mkdir /home/usuario/Documentos
chown usuario:usuario /home/usuario/Documentos
mv smb.sh /home/usuario/Documentos
}

clear
echo "ejecutar como usuario root"
echo "uso dos tarjetas de red, una en nat y otra en interna, aviso."
echo " Escoja una opcion "
echo "1. Server"
echo "2. Cliente"
read opcion
case $opcion in
    1)
        clear
        echo " Escoja una opcion "
        echo "1. Primera pregunta"
        echo "2. Segunda pregunta"
        echo "3. Tercera pregunta"
        echo "4. cuarta pregunta"
        echo "5. Quinta pregunta"
        echo "6. Sexta pregunta"
        echo "7. Septima pregunta beta"
        echo "8. Octaba pregunta beta"
        echo "9. Novena pregunta"
        echo "10. Decima pregunta"
        read opcion
        case $opcion in
        1)
            primero
        ;;
        2)
            segundo
        ;;
        3)
            tercero
        ;;
        4)
            cuarto
        ;;
        5)
            quinto
        ;;
        6)
            sexto
        ;;
        7)
            septimo
            echo "Entra desde un navegador: https://192.168.10.1:10000"
        ;;
        8)
            echo "comprueba que desde el cliente windows te puedes unir al grupo de trabajo"
        ;;
        9)
            noveno
        ;;
        10)
            decimo
        ;;
        esac
    ;;
    2)
        cliente
    ;;
esac