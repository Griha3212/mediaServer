#!/usr/bin/env bash

FLASK_PROXY_CONF_FILE=/etc/init/startMediaServer.conf
FLASK_PROXY_SERVICE_FILE=/lib/systemd/system/startMediaServer.service

FLASK_PROXY_CONF_FILE=/etc/init/startMediaServer.conf

echo "Make $FLASK_PROXY_CONF_FILE"


if [ -f "$FLASK_PROXY_CONF_FILE" ]; then
    echo "Delete old $FLASK_PROXY_CONF_FILE file"
    rm $FLASK_PROXY_CONF_FILE
fi

cat <<EOT >> $FLASK_PROXY_CONF_FILE
description "startMediaServer"
start on stopped rc RUNLEVEL=[2345]
respawn
exec sh /home/ubuntu/startMediaServer/startMediaServer.sh
EOT


echo "Make $FLASK_PROXY_SERVICE_FILE"

if [ -f "$FLASK_PROXY_SERVICE_FILE" ]; then
    echo "Delete old $FLASK_PROXY_SERVICE_FILE file"
    rm $FLASK_PROXY_SERVICE_FILE
fi

cat <<EOT >> $FLASK_PROXY_SERVICE_FILE
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