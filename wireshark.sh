#!/bin/bash

# script para usar wireshark sin sudo

sudo apt update
sudo apt install wireshark -y
sudo dpkg-reconfigure wireshark-common
sudo chmod 777 /usr/bin/dumpcap
sudo chmod 777 ~/.config/wireshark/*
