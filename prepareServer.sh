#!/usr/bin/env bash


sudo echo "deb [arch=amd64] http://ubuntu.openvidu.io/6.11.0 bionic kms6" | sudo tee /etc/apt/sources.list.d/kurento.list
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 5AFA7A83
sudo apt-get update
sudo apt-get -y install kurento-media-server
sudo sed -i "s/DAEMON_USER=\"kurento\"/DAEMON_USER=\"${USER}\"/g" /etc/default/kurento-media-server
sudo apt-get -y install coturn
sudo apt-get -y install redis-server

$YOUR_MACHINE_PUBLIC_IP=192.93.245.141

WebRtcEndpointConfig=/etc/kurento/modules/kurento/WebRtcEndpoint.conf.ini
if [ -f "$WebRtcEndpointConfig" ]; then
    echo "Delete old $WebRtcEndpointConfig file"
    rm $WebRtcEndpointConfig
fi

cat <<EOT >> $WebRtcEndpointConfig
stunServerAddress=$YOUR_MACHINE_PUBLIC_IP
stunServerPort=3478
EOT

turnserverConfigFile=/etc/turnserver.conf
if [ -f "$turnserverConfigFile" ]; then
    echo "Delete old $turnserverConfigFile file"
    rm $turnserverConfigFile
fi

cat <<EOT >> $turnserverConfigFile
external-ip=$YOUR_MACHINE_PUBLIC_IP
listening-port=3478
fingerprint
lt-cred-mech
max-port=65535
min-port=40000
pidfile="/var/run/turnserver.pid"
realm=openvidu
simple-log
redis-userdb="ip=127.0.0.1 dbname=0 password=turn connect_timeout=30"
verbose
EOT

coturnConfigFile=/etc/default/coturn
if [ -f "$coturnConfigFile" ]; then
    echo "Delete old $coturnConfigFile file"
    rm $coturnConfigFile
fi

cat <<EOT >> $coturnConfigFile
external-ip=$YOUR_MACHINE_PUBLIC_IP
listening-port=3478
fingerprint
lt-cred-mech
max-port=65535
min-port=40000
pidfile="/var/run/turnserver.pid"
realm=openvidu
simple-log
redis-userdb="ip=127.0.0.1 dbname=0 password=turn connect_timeout=30"
verbose
EOT

sudo service redis-server restart
sudo service coturn restart
sudo service kurento-media-server restart

sudo apt-get install -y openjdk-8-jre
sudo wget https://github.com/OpenVidu/openvidu/releases/download/v2.11.0/openvidu-server-2.11.0.jar
