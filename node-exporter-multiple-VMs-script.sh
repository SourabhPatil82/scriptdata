#!/bin/bash

# download the node exporter on both VMs

cd /u01

echo "########  downloading the node exporter on VM-1 ########"
echo " "

wget https://github.com/prometheus/node_exporter/releases/download/v1.3.1/node_exporter-1.3.1.linux-amd64.tar.gz

sleep 1

echo "########  downloading the node exporter on VM-2 ########"
echo " "

ssh root@10.11.0.8 "wget https://github.com/prometheus/node_exporter/releases/download/v1.3.1/node_exporter-1.3.1.linux-amd64.tar.gz"

# Extract the tar file on both VMs

echo "########## Extracting the node_exporter-1.3.1.linux-amd64.tar.gz file on VM-1 ###########"
echo " "

tar -xzf node_exporter-1.3.1.linux-amd64.tar.gz
echo " "

sleep 2

echo "########## Extracting the node_exporter-1.3.1.linux-amd64.tar.gz file on VM-2 ###########"
echo " "

ssh root@10.11.0.8 "tar -xzf node_exporter-1.3.1.linux-amd64.tar.gz"
echo " "

# Move the node exporter to specified location on VM-1

mkdir /u01/exporter

mv node_exporter-1.3.1.linux-amd64 /u01/exporter/node-exporter
echo " "

# add "nodeusr" on both VMs

echo "########## adding "nodeusr on VM-1 #############"
useradd -rs /bin/false nodeusr
echo " "

# Create systemctl services file to stop/start/status of the node exporter on both VMs

echo "########### Creating systemctl services file in VM-1 ##########"
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

# Move the node exporter to specified location on VM-2

ssh root@10.11.0.8 "mkdir -p /u01/exporter"

ssh root@10.11.0.8 "mv node_exporter-1.3.1.linux-amd64 /u01/exporter/node-exporter"
echo " "

echo "########## adding "nodeusr on VM-2 #############"
ssh root@10.11.0.8 "useradd -rs /bin/false nodeusr"
echo " "

echo "######### Creating systemctl services file in VM-2  #########"
echo " "

ssh root@10.11.0.8 "echo '[Unit]
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
WantedBy=multi-user.target' > /etc/systemd/system/node-exporter.service"
echo " "

ssh root@10.11.0.8 "chmod 777 /etc/systemd/system/node-exporter.service"

ssh root@10.11.0.8 "systemctl daemon-reload"

ssh root@10.11.0.8 "systemctl enable node-exporter"

# Start the Node exporter on both VMs

echo "######## starting the node exporter & checking status of the node exporter on VM-1 ########"
echo " "

systemctl start node-exporter
echo " "

# Status of Node exporter

if systemctl status node-exporter | grep running; then
   echo "success"
elif systemctl status node-exporter | grep failed; then
   echo "failed"
elif systemctl status node-exporter | grep inactive; then
   echo "inactive"
else
    systemctl status node-exporter
fi

echo "######## starting the node exporter & checking status of the node exporter on VM-2 ########"
echo " "

ssh root@10.11.0.8 "systemctl start node-exporter"
echo " "

# Status of Node exporter

if ssh root@10.11.0.8 "systemctl status node-exporter | grep running"; then
   echo "success"
elif ssh root@10.11.0.8 "systemctl status node-exporter | grep failed"; then
   echo "failed"
elif ssh root@10.11.0.8 "systemctl status node-exporter | grep inactive"; then
   echo "inactive"
else
   ssh root@10.11.0.8 "systemctl status node-exporter"
fi
