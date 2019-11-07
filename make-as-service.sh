#!/usr/bin/env bash

MEDIA_SERVER_CONFIG_FILE=/etc/init/startMediaServer.conf
MEDIA_SERVER_SERVICE_FILE=/lib/systemd/system/startMediaServer.service

MEDIA_SERVER_CONFIG_FILE=/etc/init/startMediaServer.conf

echo "Make $MEDIA_SERVER_CONFIG_FILE"


if [ -f "$MEDIA_SERVER_CONFIG_FILE" ]; then
    echo "Delete old $MEDIA_SERVER_CONFIG_FILE file"
    rm $MEDIA_SERVER_CONFIG_FILE
fi

cat <<EOT >> $MEDIA_SERVER_CONFIG_FILE
description "startMediaServer"
start on stopped rc RUNLEVEL=[2345]
respawn
exec sh /home/ubuntu/startMediaServer/startMediaServer.sh
EOT


echo "Make $MEDIA_SERVER_SERVICE_FILE"

if [ -f "$MEDIA_SERVER_SERVICE_FILE" ]; then
    echo "Delete old $MEDIA_SERVER_SERVICE_FILE file"
    rm $MEDIA_SERVER_SERVICE_FILE
fi

cat <<EOT >> $MEDIA_SERVER_SERVICE_FILE
[Unit]
Description=Flask Proxy Server

[Install]
WantedBy=multi-user.target

[Service]
AmbientCapabilities=CAP_SYS_RAWIO
User=nobody
WorkingDirectory=/home/ubuntu/startMediaServer
ExecStart=/home/ubuntu/startMediaServer/startMediaServer.sh
TimeoutSec=600
Restart=on-failure
RuntimeDirectoryMode=755
SyslogIdentifier=startMediaServer
EOT

cd /home/ubuntu/startMediaServer/
chmod +x startMediaServer.sh

echo "Start service"

sudo service startMediaServer start
sudo service startMediaServer status