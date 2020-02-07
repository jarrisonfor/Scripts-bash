#!/bin/bash

#Obtener grupos con uidNumber > = 1000
grep "x:[1-9][0-9][0-9][0-9]:" /etc/passwd > tmp.txt

#Crear o reiniciar archivo ldif
>tmp.ldif

#Recorrer el archivo tmp.txt con la lista de grupos
while read linea
do
	#mostrar la linea que vamos a procesar
	echo "$linea"

	#Obtener datos
	usuario=$(echo $linea | cut -d: -f1)
	apellido=$(echo $linea | cut -d: -f5 | sed "s/,/ /g" | cut -d" " -f2)
	uid=$(echo $linea | cut -d: -f3)
	gid=$(echo $linea | cut -d: -f4)

	comp=$(sudo slapcat | grep $usuario)

	if [ -z "$comp" ];
	then
	echo "voy a meter al usuario"
	#Volcar datos al archivo ldif
		echo "dn: uid=$usuario,ou=usuarios,dc=smr,dc=sor" >> tmp.ldif
		echo "objectClass: inetOrgPerson" >> tmp.ldif
		echo "objectClass: posixAccount" >> tmp.ldif
		echo "objectClass: shadowAccount" >> tmp.ldif
		echo "uid: $usuario" >> tmp.ldif 
		echo "cn: $usuario $apellido" >> tmp.ldif
		echo "sn: $usuario $apellido" >> tmp.ldif
		echo "uidNumber: $uid" >> tmp.ldif
		echo "gidNumber: $gid" >> tmp.ldif
		echo "userPassword: smr1234" >> tmp.ldif
		echo "homeDirectory: /perfiles/$usuario" >> tmp.ldif
		echo "" >> tmp.ldif
	else
	echo "no voy a meter el usuario por que ya existe"
	fi
done < tmp.txt

sudo ldapadd -x -D cn=admin,dc=smr,dc=sor -W -f tmp.ldif
