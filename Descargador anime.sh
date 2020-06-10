#!/bin/bash

while IFS= read -r line1
do
    echo $line1
    serie=$(echo "$line1" | sed 's/\ /%20/g')
    
    while IFS= read -r line2; do
        verdad=$(grep "$line2" dbmagnet.txt)
        if [[ "$verdad" != "$line2" ]]
        then
            transmission-remote --auth usuario:password -w "/home/usuario/Descargas/anime/$line1" --add "$line2"  >/dev/null 2>&1
            echo "$line2" >> dbmagnet.txt
        fi
        
    done < <( curl -sS https://www.frozen-layer.net/buscar/descargas/todos/$serie | grep -Eo "magnet:?(.*)' " | cut -d"'" -f1 )
    
done < frozen.txt

#find $directorio -type f -mtime +7 -exec rm -f {} \;
#find $directorio -type d -empty -delete


transmission-remote --auth usuario:password -l | awk '$2 == "100%"{ system("transmission-remote --auth usuario:password -t " $1 " --remove") }'