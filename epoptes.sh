#!/bin/bash
# este script arreglara el epoptes-client

sudo apt remove epoptes
sudo apt install epoptes-client

# Permisos

sudo chattr -i /etc/epoptes/*
sudo chattr -i /etc/default/epoptes*
sudo chmod 777 /etc/default/epoptes*

# epoptes-client

echo "# The server where epoptes-client will be connecting to." > /etc/default/epoptes-client
echo "# If unset, thin client user sessions running on the server will try to connect" >> /etc/default/epoptes-client
echo "# to localhost, while thin client root sessions and fat or standalone clients" >> /etc/default/epoptes-client
echo "# will try to connect to server." >> /etc/default/epoptes-client
echo "# LTSP automatically puts server in /etc/hosts for thin and fat clients," >> /etc/default/epoptes-client
echo "# but you'd need to put server in DNS manually for standalone clients." >> /etc/default/epoptes-client
echo "SERVER=172.17.200.1" >> /etc/default/epoptes-client

echo "# The port where the server will be listening on, and where the client will try" >> /etc/default/epoptes-client
echo "# to connect to. For security reasons it defaults to a system port, 789." >> /etc/default/epoptes-client
echo "#PORT=789" >> /etc/default/epoptes-client

echo "# Set Wake On LAN for devices that support it. Comment it out to disable it." >> /etc/default/epoptes-client
echo "WOL=g" >> /etc/default/epoptes-client

# epoptes

echo "# The port where the server will be listening on, and where the client will try" > /etc/default/epoptes
echo "# to connect to. For security reasons it defaults to a system port, 789." >> /etc/default/epoptes
echo "#PORT=789" >> /etc/default/epoptes

echo "# Epoptes server will use the following group for the communications socket." >> /etc/default/epoptes
echo "# That means that any user in that group will be able to launch the epoptes UI" >> /etc/default/epoptes
echo "# and control the clients." >> /etc/default/epoptes
echo "#SOCKET_GROUP=epoptes" >> /etc/default/epoptes

# inicio de epoptes-client

echo "[Desktop Entry]" > ~/.config/autostart/epoptes-client.desktop
echo "Hidden=false" >> ~/.config/autostart/epoptes-client.desktop

#terminando los ajustes

sudo chmod 644 /etc/default/epoptes*
sudo epoptes-client -c
sudo chattr +i /etc/epoptes/*
sudo chattr +i /etc/default/epoptes*
