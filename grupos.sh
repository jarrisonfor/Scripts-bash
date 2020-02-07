#!/bin/bash

#Obtener grupos con uidNumber > = 1000
grep "x:[1-9][0-9][0-9][0-9]:" /etc/group > tmp.txt

#Crear o reiniciar archivo ldif
>tmp.ldif

#Recorrer el archivo tmp.txt con la lista de grupos
while read linea
do
	#mostrar la linea que vamos a procesar
	echo "$linea"

	#Obtener datos
	cn=$(echo $linea | cut -d: -f1) # El primer campo, separando con :
	gid=$(echo $linea | cut -d: -f3)
	usuarios=$(echo $linea | cut -d: -f4 | sed "s/,/ /g")

	#Volcar datos al archivo ldif
	echo "dn: cn=$cn,ou=grupos,dc=smr,dc=sor" >> tmp.ldif
	echo "objectClass: posixGroup" >> tmp.ldif
	echo "cn: $cn" >> tmp.ldif
	echo "gidNumber: $gid" >> tmp.ldif
	echo "" >> tmp.ldif

	#añadir usuarios
	for usuario in ${usuarios};
	do
		echo "memberUid: ${usuario}" >> tmp.ldif
	done
done < tmp.txt

