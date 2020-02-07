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
		echo -e "
		dn: uid=$usuario,ou=usuarios,dc=smr,dc=sor
		objectClass: inetOrgPerson
		objectClass: posixAccount
		objectClass: shadowAccount
		uid: $usuario 
		cn: $usuario $apellido
		sn: $usuario $apellido
		uidNumber: $uid
		gidNumber: $gid
		userPassword: smr1234
		homeDirectory: /perfiles/$usuario
		
		" >> tmp.ldif
	else
	echo "no voy a meter el usuario por que ya existe"
	fi
done < tmp.txt

sudo ldapadd -x -D cn=admin,dc=smr,dc=sor -W -f tmp.ldif
