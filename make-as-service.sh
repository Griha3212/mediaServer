#!/usr/bin/env bash


MEDIA_SERVER_CONFIG_FILE=/etc/init/mediaServer.conf
MEDIA_SERVER_SERVICE_FILE=/lib/systemd/system/mediaServer.service

mkdir -p /etc/init/

echo "Make $MEDIA_SERVER_CONFIG_FILE"


if [ -f "$MEDIA_SERVER_CONFIG_FILE" ]; then
    echo "Delete old $MEDIA_SERVER_CONFIG_FILE file"
    rm $MEDIA_SERVER_CONFIG_FILE
fi

cat <<EOT >> $MEDIA_SERVER_CONFIG_FILE
description "mediaServer"
start on stopped rc RUNLEVEL=[2345]
respawn
exec sh /home/mediaServer/mediaServer.sh
EOT


echo "Make $MEDIA_SERVER_SERVICE_FILE"

if [ -f "$MEDIA_SERVER_SERVICE_FILE" ]; then
    echo "Delete old $MEDIA_SERVER_SERVICE_FILE file"
    rm $MEDIA_SERVER_SERVICE_FILE
fi

cat <<EOT >> $MEDIA_SERVER_SERVICE_FILE
[Unit]
Description=Media Server

[Install]
WantedBy=multi-user.target

[Service]
AmbientCapabilities=CAP_SYS_RAWIO
User=nobody
WorkingDirectory=/home/mediaServer/mediaServer
ExecStart=/home/mediaServer/mediaServer.sh
TimeoutSec=600
Restart=on-failure
RuntimeDirectoryMode=755
SyslogIdentifier=mediaServer
EOT

cd /home/mediaServer/

chmod +x mediaServer.sh

echo "Start service mediaServer"

sudo service mediaServer start
sudo service mediaServer status
