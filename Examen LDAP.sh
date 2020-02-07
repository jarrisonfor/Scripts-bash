#!/bin/bash

# version semi-automatizada

function LDAP { 
clear
echo "Se instalara y configurara el LDAP en el servidor con perfiles moviles, ademas creara en la raiz del usuario las plantillas necesarias para crear unidades organizativas, usuarios y grupos"
echo ""
echo "Tienes que tener 2 tarjetas de red, la PRIMERA en NAT/ADAPTADOR PUENTE y la SEGUNDA en RED INTERNA para que todo funcione a la primera"
echo ""
read -p "Pulsa enter para continuar"
clear
# Configuracion de las tarjetas de red

#--------------------------------------------------

echo "Configura las tarjetas de red"
echo ""
read -p "Pulsa enter para continuar"
sudo ifdown enp0s3
sudo ifdown enp0s8
sudo nano /etc/network/interfaces
sudo ifup enp0s3
sudo ifup enp0s8
clear
# Enrutamiento

#--------------------------------------------------

echo "#!/bin/bash" > /etc/init.d/nat.sh
echo "echo 1 > /proc/sys/net/ipv4/ip_forward" >> /etc/init.d/nat.sh
echo "iptables -A FORWARD -j ACCEPT" >> /etc/init.d/nat.sh
echo "iptables -t nat -A POSTROUTING -s 192.168.1.0/24 -o enp0s3 -j MASQUERADE" >> /etc/init.d/nat.sh
sudo chmod +x /etc/init.d/nat.sh
echo "si tienes una red diferente, tienes otras tarjetas que no sean enp0s3/8 o eres un antisistema que tiene las tarjetas al reves, no aseguro que funcione pero configura bien la red y la tarjeta de red del script que se abrira ahora, en caso contrario sal del script"
echo ""
read -p "Pulsa enter para continuar"
sudo nano /etc/init.d/nat.sh
clear
echo "Introduce esto antes del exit 0: /etc/init.d/nat.sh"
echo ""
read -p "Pulsa enter para continuar"
sudo nano /etc/rc.local
clear

#--------------------------------------------------


echo "vamos a configurar el /etc/hosts, debe quedar asi:
echo "/etc/hosts/"
echo "ipdelservidor  nombremaquina.dominio nombremaquina"
echo ""
read -p "Pulsa enter para continuar"
sudo nano /etc/hosts
echo "Dime el nombre del equipo (tiene que coincidir con el puesto en /etc/hosts)"
read equipo
echo "$equipo" > /etc/hostname
sudo hostname $equipo
clear

#--------------------------------------------------

sudo apt update
sudo apt install slapd ldap-utils nfs-common nfs-kernel-server -y

#--------------------------------------------------

sudo apt install libnss-ldap libpam-ldap ldap-utils sysv-rc-conf -y
clear
echo "tienes que poner ldap en los compat, quedaria algo asi: compat ldap"
echo ""
read -p "Pulsa enter para continuar"
sudo nano /etc/nsswitch.conf

#--------------------------------------------------

clear
echo "Tienes que eliminar la palabra: use_authok"
echo ""
read -p "Pulsa enter para continuar"
sudo nano /etc/pam.d/common-password
echo "session optional pam_mkhomedir.so skel=/etc/skel umask=077" >> /etc/pam.d/common-session
sudo sysv-rc-conf libnss-ldap on

#--------------------------------------------------

clear
echo "vamos a crear la carpeta movil, tendras que darme la ruta COMPLETA (ABSOLUTA) donde se guardaran los usuarios (si no existe la creare)"
read ruta
sudo mkdir -p $ruta
sudo chmod -R 777 $ruta
sudo chown -R nobody:nogroup $ruta
echo "$ruta *(rw,sync,no_root_squash,no_subtree_check)" >> /etc/exports

# Creacion de plantillas .ldif

#--------------------------------------------------

echo "dn: ou=nombre,dc=dominio" > ~/unidades.ldif
echo "objectClass: organizationalUnit" >> ~/unidades.ldif
echo "ou: nombre" >> ~/unidades.ldif

#--------------------------------------------------

echo "dn: cn=nombre,dc=dominio" > ~/grupos.ldif
echo "objectClass: posixGroup" >> ~/grupos.ldif
echo "cn: nombre" >> ~/grupos.ldif
echo "gidNumber: 10000" >> ~/grupos.ldif

#--------------------------------------------------

echo "dn: uid=nombre,ou=usuarios,dc=smr,dc=sor" > ~/usuarios.ldif
echo "objectClass: inetOrgPerson" >> ~/usuarios.ldif
echo "objectClass: posixAccount" >> ~/usuarios.ldif
echo "objectClass: shadowAccount" >> ~/usuarios.ldif
echo "uid: nombre" >> ~/usuarios.ldif
echo "sn: apellido" >> ~/usuarios.ldif
echo "cn: nombre y apellido" >> ~/usuarios.ldif
echo "uidNumber: 2000" >> ~/usuarios.ldif
echo "gidNumber: 10000" >> ~/usuarios.ldif
echo "userPassword: contraseña" >> ~/usuarios.ldif
echo "homeDirectory: $ruta /usuario" >> ~/usuarios.ldif

#--------------------------------------------------

clear
echo "El sistema se reiniciara"
echo ""
read -p "Pulsa enter para continuar"

}

function LDAPcliente {
            echo "Configura las tarjetas de red"
            echo ""
            read -p "Pulsa enter para continuar"
            sudo ifdown enp0s3
            sudo nano /etc/network/interfaces
            sudo ifup enp0s3
            clear
            sudo apt install libnss-ldap libpam-ldap ldap-utils sysv-rc-conf nfs-common rpcbind -y
            clear
            echo "tienes que poner ldap en los compat, quedaria algo asi: compat ldap"
            echo ""
            read -p "Pulsa enter para continuar"
            sudo nano /etc/nsswitch.conf
            
            #--------------------------------------------------
            
            clear
            echo "Tienes que eliminar la palabra: use_authok"
            echo ""
            read -p "Pulsa enter para continuar"
            sudo nano /etc/pam.d/common-password
            echo "session optional pam_mkhomedir.so skel=/etc/skel umask=077" >> /etc/pam.d/common-session
            sudo sysv-rc-conf libnss-ldap on
            
            #--------------------------------------------------
            
            clear
            echo "vamos a crear la carpeta movil, tendras que darme la ruta COMPLETA (ABSOLUTA) donde se guardaran los usuarios (si no existe la creare)"
            read rutac
            sudo mkdir -p $rutac
            sudo chmod -R 777 $rutac
            sudo chown -R nobody:nogroup $rutac
            clear
            echo "Dame la ruta de la carpeta compartida en el servidor"
            read rutas


            echo "192.168.1.1:$rutas $rutac nfs auto,noatime,nolock,bg,nfsvers=3,intr,tcp,actimeo=1800 0 0" >> /etc/fstab

            echo "el sistema necesita reiniciarse para que todo funcione"
            echo ""
            read -p "Pulsa enter para continuar"
            sudo reboot
}

function SAMBA {

}

function fixserver {
clear
sudo dpkg-reconfigure slapd
sudo dpkg-reconfigure ldap-auth-config
sudo dpkg-reconfigure libnss-ldap libpam-ldap ldap-utils sysv-rc-conf
sudo dpkg-reconfigure acl attr autoconf bind9utils bison build-essential debhelper dnsutils docbook-xml docbook-xsl flex gdb libjansson-dev krb5-user libacl1-dev libaio-dev libarchive-dev libattr1-dev libblkid-dev libbsd-dev libcap-dev libcups2-dev libgnutls-dev libgpgme11-dev libjson-perl libldap2-dev libncurses5-dev libpam0g-dev libparse-yapp-perl libpopt-dev libreadline-dev nettle-dev perl perl-modules pkg-config python-all-dev python-crypto python-dbg python-dev python-dnspython python3-dnspython python-gpgme python3-gpgme python-markdown python3-markdown python3-dev xsltproc zlib1g-dev
}

function fixcliente {
    sudo dpkg-reconfigure libnss-ldap libpam-ldap ldap-utils sysv-rc-conf
}

#   Menu principal

while ["$opcion" != 3 ]; do
clear
echo " Escoja una opcion "
echo "1. Server"
echo "2. Cliente"
echo "3. Salir"
read opcion
case $opcion in
    1)
        while ["$opcion" != 4 ]; do
        clear
        echo " Escoja una opcion "
        echo "1. Instalar LDAP con perfiles moviles"
        echo "2. Instalar SAMBA"
        echo "3. Intentar arreglarlo todo."
        echo "4. Atras"
        read opcion
        case $opcion in
        1)
            LDAP
        ;;
        2)
            SAMBA
        ;;
        3)
            fixserver
        ;;
        4)
            echo ""
        ;;    
        *)
            clear
            echo "Opcion no valida..."
        ;;
        esac
        done
    ;;
    2)
        while ["$opcion" != 3 ]; do
        clear
        echo " Escoja una opcion "
        echo "1. Instalar Cliente LDAP con perfiles moviles"
        echo "2. Instalar SAMBA"
        echo "3. Atras"
        read opcion
        case $opcion in
        1)
            LDAPcliente
        ;;
        2)
            fixcliente
        ;;
        
        3)
            echo ""
        ;;
        *)
            clear
            echo "Opcion no valida..."
        ;;
        esac
        done
    ;;
    3)
    clear
    echo "Bye."
    echo ""
    echo ""
    exit
    ;;
    *)
        clear
        echo "Opcion no valida..."
    ;;
esac
done