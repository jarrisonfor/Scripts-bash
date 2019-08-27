#!/bin/bash

# plantilla: sudo ufw <allow o deny> from <ip> proto <tcp o udp> to any port <puerto>
sudo apt update
sudo apt install ufw gufw
sudo ufw enable
sudo ufw default reject
sudo ufw default allow outgoing
clear
echo "¿Que quieres hacer?"
echo "1. Permitir la entrada por SSH a el profesor"
echo "2. Permitir la entrada por SSH a Yeray"
echo "3. Configurar la regla manualmente"
read Opcion
case $Opcion in

1)
clear
sudo ufw allow from 172.16.200.1 proto tcp to any port 22
;;

2)
clear
sudo ufw allow from 172.16.57.255 proto tcp to any port 22
;;

3)
clear
echo "Se permitira o denegara los puertos de una IP especifica."
echo "¿allow (Permitir) o deny (Denegar)?"
read Permiso
clear
echo "Se permitira o denegara los puertos de una IP especifica."
echo "¿Direccion IP?"
read IP
clear
echo "Se permitira o denegara los puertos de una IP especifica."
echo "¿tcp o udp?"
read Protocolo
clear
echo "Se permitira o denegara los puertos de una IP especifica."
echo "¿Puerto?"
read Puerto
clear
sudo ufw $Permiso from $IP proto $Protocolo to any port $Puerto
;;

*)
clear
echo "No existe esa opcion, vuelve a intentarlo"
sleep 5
./Cortafuegos.sh
;;
esac
