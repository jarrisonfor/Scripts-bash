#!/bin/bash
if [ -f "$2" ]; then
    case "$1" in
        -i)
            # instalacion
            sudo apt update && sudo apt upgrade -y
            sudo apt install ssh composer npm fish apache2 apache2-utils mysql-server zip unzip php php-mysql php-zip libapache2-mod-php php-cli php-common php-mbstring php-gd php-intl php-xml php-mysql php-zip php-curl php-xmlrpc -y
            sudo mysql_secure_installation
            read -p 'Contraseña para el mysql' password
            sudo mysql -u root -e "CREATE DATABASE $USER"
            sudo mysql -u root -e "CREATE USER '$USER'@'%' IDENTIFIED BY '$password'"
            sudo mysql -u root -e "GRANT ALL PRIVILEGES ON *.* TO '$USER'@'%' WITH GRANT OPTION"
            sudo rm /var/www/html/index.html
            sudo wget https://www.adminer.org/latest.php -O /var/www/html/adminer.php
            sudo wget https://www.phpmyadmin.net/downloads/phpMyAdmin-latest-all-languages.zip -O /var/www/html/phpmyadmin.zip
            sudo unzip -oq /var/www/html/phpmyadmin.zip -d /var/www/html/
            sudo mv /var/www/html/phpMyAdmin* /var/www/html/phpmyadmin/
            sudo rm /var/www/html/phpmyadmin.zip

            sudo mv /var/www/html/phpmyadmin/config.sample.inc.php /var/www/html/phpmyadmin/config.inc.php
            sudo sed -i "/blowfish_secret/ c \$cfg['blowfish_secret'] = 'iVkv2U2E}E9bgpGWhUg-DpYUQf;h7rxN';" /var/www/html/phpmyadmin/config.inc.php
            sudo chown www-data:www-data /var/www/html/* -R

            sudo a2dissite 000-default.conf
            sudo a2ensite default-ssl.conf
            sudo a2enmod userdir rewrite headers ssl
            
            sudo sed -i "/php_admin_flag engine Off/ c #php_admin_flag engine Off" /etc/apache2/mods-available/php7.*.conf
            
            sudo sed -i '/#/ d' /etc/apache2/sites-available/default-ssl.conf
            sudo sed -i '/<VirtualHost _default_:443>/ a ServerName proyecto-asir.ddns.net' /etc/apache2/sites-available/default-ssl.conf
            sudo sed -i '/DocumentRoot/ a <Directory /var/www/html> \n Options Indexes FollowSymLinks \n AllowOverride All \n Require all granted \n</Directory>' /etc/apache2/sites-available/default-ssl.conf
            sudo sed -i '/DocumentRoot/ a <Directory /home/*/public_html> \n Options Indexes FollowSymLinks \n AllowOverride All \n Require all granted \n</Directory>' /etc/apache2/sites-available/default-ssl.conf
            
            sudo service apache2 restart
            
            mkdir ~/.vscode
            mkdir ~/public_html
            sudo chmod 700 ~/bin/
            sudo chown :www-data ~/public_html -R
            sudo chmod u+rwx,g+rwxs ~/public_html -R
            echo -e '{\n "files.exclude": {\n "**/.*": true \n } \n}' > ~/.vscode/settings.json
            sudo cp -r ~/.vscode /home/
            sudo cp -r ~/.vscode /etc/skel/
            sudo mkdir /etc/skel/public_html
            sudo chown root:root /etc/skel/.vscode/ -R
            sudo chmod u+rwx,g+rwxs,o-rwx /etc/skel/* -R
            
            sudo service apache2 restart
        ;;
        -c)
            # creacion de usuarios leyendo archivo
            while read linea
            do
                alumno=$linea
                password="csas1234"
                sudo useradd $alumno -m -s /bin/bash -K UMASK=007
                echo -e "$password\n$password\n" | sudo passwd $alumno &> /dev/null
                sudo usermod -a -G $(id -g $alumno) $USER
                sudo usermod -a -G $(id -g $alumno) www-data
                sudo mysql -u root -e "CREATE DATABASE $alumno"
                sudo mysql -u root -e "CREATE USER '$alumno'@'%' IDENTIFIED BY '$password'"
                sudo mysql -u root -e "GRANT ALL PRIVILEGES ON $alumno.* TO '$alumno'@'%'"
            done < $2
            # Permisos
            sudo chown $USER /home/*
            
            echo "Se reiniciara la maquina para recargar los cambios"
            sleep 10
            sudo reboot
        ;;
        -b)
            # borrado de usuarios leyendo archivo
            sudo service mysql restart
            while read linea
            do
                alumno=$linea
                sudo killall -u $alumno
                sudo deluser --remove-home -f $alumno &> /dev/null
                sudo gpasswd -d $USER $alumno &> /dev/null
                sudo gpasswd -d www-data $alumno &> /dev/null
                sudo delgroup $alumno &> /dev/null
                sudo mysql -u root -e "DROP DATABASE $alumno"
                sudo mysql -u root -e "DROP USER '$alumno'@'%'"
            done < $2
            
            echo "Se reiniciara la maquina para recargar los cambios"
            sleep 10
            sudo reboot
        ;;
        *)
            echo -e "Parametros permitidos: \n -c: Crear los usuarios \n -b: Borrar los usuarios"
        ;;
    esac
else
    echo "El fichero no existe"
fi
