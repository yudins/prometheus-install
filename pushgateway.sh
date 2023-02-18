#!/bin/bash

# Make pushgateway user
sudo adduser --no-create-home --disabled-login --shell /bin/false --gecos "Pushgateway User" pushgateway

# Download pushgateway and copy utilities to where they should be in the filesystem
#VERSION=0.15.0
VERSION=$(curl https://raw.githubusercontent.com/prometheus/pushgateway/master/VERSION)
wget https://github.com/prometheus/pushgateway/releases/download/v${VERSION}/pushgateway-${VERSION}.linux-amd64.tar.gz
tar xvzf pushgateway-${VERSION}.linux-amd64.tar.gz

sudo cp pushgateway-${VERSION}.linux-amd64/pushgateway /usr/local/bin/
sudo chown pushgateway:pushgateway /usr/local/bin/pushgateway

# Populate configuration files
cat ./pushgateway/pushgateway.service | sudo tee /etc/systemd/system/pushgateway.service

# systemd
sudo systemctl daemon-reload
sudo systemctl enable pushgateway
sudo systemctl start pushgateway
sleep 5s
sudo systemctl staus pushgateway

# Installation cleanup
rm pushgateway-${VERSION}.linux-amd64.tar.gz
rm -rf pushgateway-${VERSION}.linux-amd64