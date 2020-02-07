#!/bin/bash
slapcat | grep "uid: " | cut -d" " -f2 > tmp.txt

while read linea
do
        echo "$linea"
        useradd $linea
        (echo "smr1234"; echo "smr1234") | smbpasswd -a -s $linea
done < tmp.txt
