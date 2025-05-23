#!/bin/bash
#Installation of required tools and some nice to have

sudo apt update
sudo apt upgrade -y
sudo apt install -y htop vim-nox vnstat qemu-guest-agent openssh-server

### Docker

sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update

sudo apt-cache policy docker-ce
sudo apt install -y docker-ce
sudo systemctl --no-pager status docker
sudo usermod -aG docker $USER

echo
echo "---------------------------------------------------"
echo "  Logga ut och in igen för att kunna köra docker   "
echo "  Kör sen start_all.sh                             "
echo "---------------------------------------------------"
echo
