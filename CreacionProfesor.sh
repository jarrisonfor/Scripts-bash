#!/bin/bash

case "$1" in
    -i)
        # instalacion y habilitacion
        sudo apt update && sudo apt upgrade -y
        sudo apt install ssh composer npm fish quota quotatool apache2 apache2-utils mysql-server zip unzip php php-mysql php-zip libapache2-mod-php php-cli php-common php-mbstring php-gd php-intl php-xml php-mysql php-zip php-curl php-xmlrpc -y
        sudo a2dissite 000-default.conf
        sudo a2ensite default-ssl.conf
        sudo a2enmod userdir rewrite headers ssl
        sudo quotacheck -a -g -u -m -c -f -i -n
        
        # Configuracion de base de datos y creacion de usuario con todos los privilegios
        sudo service mysql restart
        sudo mysql_secure_installation
        read -p 'Contraseña para el mysql: ' password
        sudo mysql -u root -e "CREATE DATABASE $USER"
        sudo mysql -u root -e "CREATE USER '$USER'@'%' IDENTIFIED BY '$password'"
        sudo mysql -u root -e "GRANT ALL PRIVILEGES ON *.* TO '$USER'@'%' WITH GRANT OPTION"
        
        # Creacion de carpetas
        mkdir ~/.vscode
        mkdir ~/public_html
        mkdir ~/Descargas
        sudo mkdir /etc/skel/public_html
        
        # Configuracion para el editor de visual studio, ocultara los archivos que empiecen por . como por ejemplo .bashrc
        echo -e '{\n "files.exclude": {\n "**/.*": true \n } \n}' > ~/.vscode/settings.json
        # Descarga de clientes web para la base de datos
        sudo wget https://www.adminer.org/latest.php -O /var/www/html/adminer.php
        sudo wget https://www.phpmyadmin.net/downloads/phpMyAdmin-latest-all-languages.zip -O /var/www/html/phpmyadmin.zip
        
        # movemos todo a su sitio y le ponemos sus permisos correspondientes
        sudo cp -r ~/.vscode /home/
        sudo cp -r ~/.vscode /etc/skel/
        sudo unzip -oq /var/www/html/phpmyadmin.zip -d /var/www/html/
        sudo mv /var/www/html/phpMyAdmin* /var/www/html/phpmyadmin/
        sudo mv /var/www/html/phpmyadmin/config.sample.inc.php /var/www/html/phpmyadmin/config.inc.php
        sudo rm /var/www/html/index.html
        sudo rm /var/www/html/phpmyadmin.zip
        sudo chown root:root /etc/skel/.vscode/ -R
        sudo chown :www-data ~/public_html -R
        sudo chown www-data:www-data /var/www/html/* -R
        sudo chmod u+rwx,g+rwxs,o-rwx /etc/skel/* -R
        sudo chmod u+rwx,g+rwxs ~/public_html -R
        
        # Modificacion de archivos
        sudo sed -i '/#/ d' /etc/apache2/sites-available/default-ssl.conf
        sudo sed -i '/<VirtualHost _default_:443>/ a ServerName proyecto-asir.ddns.net' /etc/apache2/sites-available/default-ssl.conf
        sudo sed -i '/DocumentRoot/ a <Directory /var/www/html> \n Options Indexes FollowSymLinks \n AllowOverride All \n Require all granted \n</Directory>' /etc/apache2/sites-available/default-ssl.conf
        sudo sed -i '/DocumentRoot/ a <Directory /home/*/public_html> \n Options Indexes FollowSymLinks \n AllowOverride All \n Require all granted \n</Directory>' /etc/apache2/sites-available/default-ssl.conf
        sudo sed -i "/blowfish_secret/ c \$cfg['blowfish_secret'] = 'iVkv2U2E}E9bgpGWhUg-DpYUQf;h7rxN';" /var/www/html/phpmyadmin/config.inc.php
        sudo sed -i "/php_admin_flag engine Off/ c #php_admin_flag engine Off" /etc/apache2/mods-available/php7.*.conf
        sudo sed -i 's/defaults/defaults,usrquota,grpquota/g' /etc/fstab
        
        clear
        echo "Se reiniciara la maquina para recargar los cambios"
        sleep 10
        sudo reboot
    ;;
    -cl)
        # creacion de usuarios leyendo archivo
        while read linea
        do
            # aqui definimos las variables del usuario y la contraseña
            alumno=$linea
            password="csas1234"
            # creacion del usuario
            sudo useradd $alumno -m -s /bin/bash -K UMASK=007
            echo -e "$password\n$password\n" | sudo passwd $alumno &> /dev/null
            # esto es lo que hace que el profesor y apache pueda entrar en en los alumnos 
            sudo usermod -a -G $(id -g $alumno) $USER
            sudo usermod -a -G $(id -g $alumno) www-data
            # creacion de la base de datos y su usuario
            sudo mysql -u root -e "CREATE DATABASE $alumno"
            sudo mysql -u root -e "CREATE USER '$alumno'@'%' IDENTIFIED BY '$password'"
            sudo mysql -u root -e "GRANT ALL PRIVILEGES ON $alumno.* TO '$alumno'@'%'"
            sudo mysql -u root -e "GRANT SELECT, SHOW VIEW ON $USER.* TO '$alumno'@'%'"
            # le añadimos una cuota de 1gb, a los 512mb tendra una notificacion en el terminal
            sudo setquota -u $alumno 524288 1048576 0 0 /
        done < $2
        # hacer dueño de todas carpetas de usuarios al profesor
        sudo chown $USER /home/*
        
        echo "Se reiniciara la maquina para recargar los cambios"
        sleep 20
        sudo reboot
    ;;
    -bl)
        # borrado de usuarios leyendo archivo
        # reiniciamos el servicio para asegurarnos que se cierran todos los procesos y los usuarios
        sudo service mysql restart
        while read linea
        do
            alumno=$linea
            # kickeamos al usuario para poder borrarlo
            sudo killall -u $alumno
            # borramos el usuario y su carpeta
            sudo deluser --remove-home -f $alumno &> /dev/null
            # quitamos los grupos del usuario profesor y apache
            sudo gpasswd -d $USER $alumno &> /dev/null
            sudo gpasswd -d www-data $alumno &> /dev/null
            # borramos los grupos del sistema
            sudo delgroup $alumno &> /dev/null
            # borramos su base de datos y su usuario
            sudo mysql -u root -e "DROP DATABASE $alumno"
            sudo mysql -u root -e "DROP USER '$alumno'@'%'"
        done < $2
        
        echo "Se reiniciara la maquina para recargar los cambios"
        sleep 20
        sudo reboot
    ;;
    -cu)
        # creacion de un usuario individual (es igual al de lotes pero sin el while)
        alumno=$2
        password="csas1234"
        sudo useradd $alumno -m -s /bin/bash -K UMASK=007
        echo -e "$password\n$password\n" | sudo passwd $alumno &> /dev/null
        sudo usermod -a -G $(id -g $alumno) $USER
        sudo usermod -a -G $(id -g $alumno) www-data
        sudo mysql -u root -e "CREATE DATABASE $alumno"
        sudo mysql -u root -e "CREATE USER '$alumno'@'%' IDENTIFIED BY '$password'"
        sudo mysql -u root -e "GRANT ALL PRIVILEGES ON $alumno.* TO '$alumno'@'%'"
        sudo mysql -u root -e "GRANT SELECT, SHOW VIEW ON $USER.* TO '$alumno'@'%'"
        sudo setquota -u $alumno 524288 1048576 0 0 /
        sudo chown $USER /home/*
        
        echo "se aconseja reiniciar la maquina para que los cambios tengan efecto"
    ;;
    -bu)
        # borrado de un usuario individual (es igual al de lotes pero sin el while)
        sudo service mysql restart
        alumno=$2
        sudo killall -u $alumno
        sudo deluser --remove-home -f $alumno &> /dev/null
        sudo gpasswd -d $USER $alumno &> /dev/null
        sudo gpasswd -d www-data $alumno &> /dev/null
        sudo delgroup $alumno &> /dev/null
        sudo mysql -u root -e "DROP DATABASE $alumno"
        sudo mysql -u root -e "DROP USER '$alumno'@'%'"
        
        echo "se aconseja reiniciar la maquina para que los cambios tengan efecto"
    ;;
    *)
        echo -e "Parametros permitidos: \n -i: Instalar todo lo necesario (solo la primera vez) \n -cl: Crear los usuarios en lote ej: script.sh -cl listaalumnos.txt \n -bl: Borrar los usuarios en lote ej: script.sh -bl listaalumnos.txt \n -cu: Crea un usuario ej: script.sh -cu pepito \n -bu: Borrar un usuario ej: script.sh -bu pepito"
    ;;
esac
