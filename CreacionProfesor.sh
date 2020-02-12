#!/bin/bash
if [ -f "$2" ]; then
    case "$1" in
        -c)
            # creacion de usuarios leyendo archivo
            while read linea
            do
                password="csas1234"
                alumno=$linea
                sudo useradd $alumno -m -K UMASK=007
                echo -e "$password\n$password\n" | sudo passwd $alumno &> /dev/null
                sudo usermod -a -G $(id -g $alumno) profesor
                sudo usermod -a -G $(id -g $alumno) www-data
            done < $2
            # Permisos
            sudo chown profesor /home/*
            sudo service apache2 restart
            echo "Se saldra de la sesion para que surgan los efectos de los grupos"
            exit
        ;;
        -b)
            # borrado de usuarios leyendo archivo
            while read linea
            do
                alumno=$linea
                sudo deluser --remove-home $alumno &> /dev/null
                sudo gpasswd -d profesor $alumno &> /dev/null
                sudo gpasswd -d www-data $alumno &> /dev/null
                sudo delgroup $alumno &> /dev/null
            done < $2
            sudo service apache2 restart
            echo "Se saldra de la sesion para que surgan los efectos de los grupos"
            exit
        ;;
        *)
            echo -e "Parametros permitidos: \n -c: Crear los usuarios \n -b: Borrar los usuarios"
        ;;
    esac
else
    echo "El fichero no existe"
fi
