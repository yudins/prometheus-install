#!/bin/bash

# Export CONSUL_EXPORTER_TOKEN to env
# export CONSUL_EXPORTER_TOKEN=YOUR_TOKEN

# Make consul_exporter user
sudo adduser --no-create-home --disabled-login --shell /bin/false --gecos "Consul Exporter User" consul_exporter

# Download consul_exporter and copy utilities to where they should be in the filesystem
#VERSION=0.9.0
VERSION=$(curl https://raw.githubusercontent.com/prometheus/consul_exporter/master/VERSION)
echo "[INFO] Consul exporter version: $VERSION"
wget -q https://github.com/prometheus/consul_exporter/releases/download/v${VERSION}/consul_exporter-${VERSION}.linux-amd64.tar.gz
tar xvzf consul_exporter-${VERSION}.linux-amd64.tar.gz

sudo cp consul_exporter-${VERSION}.linux-amd64/consul_exporter /usr/local/bin/
sudo chown consul_exporter:consul_exporter /usr/local/bin/consul_exporter

# Add service to systemd
cat > /etc/systemd/system/consul_exporter.service <<- EOF
[Unit]
Description=Consul exporter service
Wants=network-online.target
After=network.target

[Service]
User=consul_exporter
Group=consul_exporter
Type=simple
Environment="CONSUL_HTTP_TOKEN=$CONSUL_EXPORTER_TOKEN"
ExecStart=/usr/local/bin/consul_exporter \
    --consul.server="http://localhost:8500"
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# systemd
sudo systemctl daemon-reload
sudo systemctl enable consul_exporter
sudo systemctl start consul_exporter

# Installation cleanup
rm consul_exporter-${VERSION}.linux-amd64.tar.gz
rm -rf consul_exporter-${VERSION}.linux-amd64
