#!/bin/bash

conectado=$(netstat -pt | grep "$1:ssh" | tr -s " " | cut -d" " -f6)
clear

if [ -z $conectado ];
then
	puerto=$(nmap -Pn $1 -p 22 | grep 22/tcp | cut -d" " -f2)
	if [ $puerto = "filtered" ] || [ $puerto = "closed" ];
	then
		echo "El puerto esta cerrado, se tocara la puerta."
		knock $1 7000 8000 9000
		sleep 3
		ssh $1
		exit 0
	else
		ssh $1
		knock $1 9000 8000 7000
		exit 0
	fi	
else
	echo "Ya esta conectado a $1, no se haran mas opciones"
fi
exit 0
