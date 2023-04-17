#!/bin/bash

# download the node exporter

cd /u01

echo "########  downloading the node exporter ########"
echo " "

wget https://github.com/prometheus/node_exporter/releases/download/v1.3.1/node_exporter-1.3.1.linux-amd64.tar.gz

# Extract the tar file

echo "########## Extracting the node_exporter-1.3.1.linux-amd64.tar.gz file ###########"
echo " "

tar -xzvf node_exporter-1.3.1.linux-amd64.tar.gz
echo " "

# Move the node exporter to specified location

mkdir -p /u01/exporter

mv node_exporter-1.3.1.linux-amd64 /u01/exporter/node-exporter 
echo " "

# add nodeusr

useradd -rs /bin/false nodeusr

# Create systemctl services file to stop/start/status of the node exporter

echo "######### Creating systemctl services file #########"
echo " "

echo "[Unit]
Description=Node Exporter
After=network.target

[Service]
Type=simple
User=nodeusr
Group=nodeusr
ExecReload=/bin/kill -HUP $MAINPID
ExecStart=/bin/bash -c /u01/exporter/node-exporter/node_exporter \
    --collector.cpu \
    --collector.diskstats \
    --collector.filesystem \
    --collector.loadavg \
    --collector.meminfo \
    --collector.filefd \
    --collector.netdev \
    --collector.stat \
    --collector.netstat \
    --collector.systemd \
    --collector.uname \
    --collector.vmstat \
    --collector.time \
    --collector.mdadm \
    --collector.zfs \
    --collector.tcpstat \
    --collector.bonding \
    --collector.hwmon \
    --collector.arp \
    --web.listen-address=:9100 \
    --web.telemetry-path="/metrics"
[Install]
WantedBy=multi-user.target" > /etc/systemd/system/node-exporter.service
echo " "

chmod 777 /etc/systemd/system/node-exporter.service

systemctl daemon-reload

systemctl enable node-exporter

# Start the Node exporter

echo "######## starting the node exporter & checking status of the node exporter ########"
echo " "

sudo systemctl start node-exporter
echo " "

# Status of Node exporter

if sudo systemctl status node-exporter | grep running; then
   echo "success"
elif sudo systemctl status node-exporter | grep failed; then
   echo "failed"
elif sudo systemctl status node-exporter | grep inactive; then
   echo "inactive"
else
   sudo systemctl status node-exporter
fi
