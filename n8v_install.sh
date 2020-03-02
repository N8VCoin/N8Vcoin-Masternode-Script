#!/bin/bash

TMP_FOLDER=$(mktemp -d)
CONFIG_FILE='nativecoin.conf'
CONFIGFOLDER='/root/.nativecoin'
COIN_DAEMON='nativecoind'
COIN_CLI='nativecoin-cli'
COIN_PATH='/usr/local/bin/'
COIN_REPO='https://github.com/n8VCoin/N8Vcoin'
COIN_TGZ='https://github.com/N8VCoin/nativecoin/releases/download/1.2/nativecoin-1.2-x86_64-linux-gnu.tar.gz'
COIN_ZIP=$(echo $COIN_TGZ | awk -F'/' '{print $NF}')
COIN_NAME='NativeCoin'
COIN_PORT=8848
RPC_PORT=8849

NODEIP=$(curl -s4 icanhazip.com)


BLUE="\033[0;34m"
YELLOW="\033[0;33m"
CYAN="\033[0;36m"
PURPLE="\033[0;35m"
RED='\033[0;31m'
GREEN="\033[0;32m"
NC='\033[0m'
MAG='\e[1;35m'


function download_node() {
  echo -e "${GREEN}Downloading and Installing Masternode for $COIN_NAME ${NC}"
  OLD_DIR=$(pwd)
  cd $TMP_FOLDER >/dev/null 2>&1
  wget -q $COIN_TGZ
  compile_error
  tar xvzf $COIN_ZIP >/dev/null 2>&1
  cd daemon >/dev/null 2>&1
  chmod +x * >/dev/null 2>&1
  mv $COIN_DAEMON $COIN_CLI $COIN_PATH >/dev/null 2>&1
  cd $(OLD_DIR) >/dev/null 2>&1
  rm -rf $TMP_FOLDER >/dev/null 2>&1
  clear
}


function configure_systemd() {
  cat << EOF > /etc/systemd/system/$COIN_NAME.service
[Unit]
Description=$COIN_NAME service
After=network.target

[Service]
User=root
Group=root

Type=forking
#PIDFile=$CONFIGFOLDER/$COIN_NAME.pid

ExecStart=$COIN_PATH$COIN_DAEMON -daemon
ExecStop=$COIN_PATH$COIN_CLI stop

Restart=always
PrivateTmp=true
TimeoutStopSec=60s
TimeoutStartSec=10s
StartLimitInterval=120s
StartLimitBurst=5

[Install]
WantedBy=multi-user.target
EOF

  systemctl daemon-reload
  sleep 3
  systemctl start $COIN_NAME.service
  systemctl enable $COIN_NAME.service >/dev/null 2>&1

  if [[ -z "$(ps axo cmd:100 | egrep $COIN_DAEMON)" ]]; then
    echo -e "${RED}$COIN_NAME is not running${NC}, please investigate. You should start by running the following commands as root:"
    echo -e "${GREEN}systemctl start $COIN_NAME.service"
    echo -e "systemctl status $COIN_NAME.service"
    echo -e "less /var/log/syslog${NC}"
    exit 1
  fi
}


function create_config() {
  mkdir $CONFIGFOLDER >/dev/null 2>&1
  RPCUSER=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 10 | head -n 1)
  RPCPASSWORD=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 20 | head -n 1)
  cat << EOF > $CONFIGFOLDER/$CONFIG_FILE
rpcuser=$RPCUSER
rpcpassword=$RPCPASSWORD
rpcallowip=127.0.0.1
rpcport=$RPC_PORT
listen=1
server=1
daemon=1
port=$COIN_PORT
EOF
}

function create_key() {
  echo -e "${YELLOW}Please enter your ${RED}$COIN_NAME Masternode GEN Key${NC}."
  read -e COINKEY
  if [[ -z "$COINKEY" ]]; then
  $COIN_DAEMON -daemon
  sleep 30
  if [ -z "$(ps axo cmd:100 | grep $COIN_DAEMON)" ]; then
   echo -e "${RED}$COIN_NAME server couldn not start. Check /var/log/syslog for errors.{$NC}"
   exit 1
  fi
  COINKEY=$($COIN_CLI createmasternodekey)
  if [ "$?" -gt "0" ];
    then
    echo -e "${RED}Wallet not fully loaded. Let us wait and try again to generate the Private Key${NC}"
    sleep 30
    COINKEY=$($COIN_CLI createmasternodekey)
  fi
  $COIN_CLI stop
fi
clear
}

function update_config() {
  sed -i 's/daemon=1/daemon=0/' $CONFIGFOLDER/$CONFIG_FILE
  cat << EOF >> $CONFIGFOLDER/$CONFIG_FILE
maxconnections=256
masternode=1
externalip=$NODEIP:$COIN_PORT
masternodeprivkey=$COINKEY
logtimestamps=1
masternodeaddr=$NODEIP:$COIN_PORT

#Nodes
addnode=1.119.137.186
addnode=104.207.157.167
addnode=104.238.154.99
addnode=140.82.19.83
addnode=140.82.3.21
addnode=144.202.95.248
addnode=149.28.161.55
addnode=149.28.37.90
addnode=155.138.227.193
addnode=157.230.224.154
addnode=159.89.117.254
addnode=165.22.50.200
addnode=174.16.189.27
addnode=206.189.163.62
addnode=207.246.92.196
addnode=24.17.34.52
addnode=45.32.144.9
addnode=45.63.70.41
addnode=45.63.77.24
addnode=45.76.188.182
addnode=45.76.242.10
addnode=45.77.211.184
addnode=50.125.73.237
addnode=66.42.93.213
addnode=71.33.164.190
addnode=71.33.192.100
addnode=73.109.60.71
addnode=76.121.62.235
addnode=78.141.198.101
addnode=80.211.87.33
addnode=81.11.161.240
addnode=85.19.25.38
addnode=95.179.194.15
addnode=95.179.252.213
addnode=95.216.193.2


EOF
}


function enable_firewall() {
  echo -e "Installing and setting up firewall ${GREEN}$COIN_PORT${NC}"
  ufw allow $COIN_PORT/tcp comment "$COIN_NAME MN port" >/dev/null
  #ufw allow $RPCPORT/tcp comment "$COIN_NAME RPC port" >/dev/null
  ufw allow ssh comment "SSH" >/dev/null 2>&1
  ufw limit ssh/tcp >/dev/null 2>&1
  ufw default allow outgoing >/dev/null 2>&1
  echo "y" | ufw enable >/dev/null 2>&1
}



function get_ip() {
  declare -a NODE_IPS
  for ips in $(netstat -i | awk '!/Kernel|Iface|lo/ {print $1," "}')
  do
    NODE_IPS+=($(curl --interface $ips --connect-timeout 2 -s4 icanhazip.com))
  done

  if [ ${#NODE_IPS[@]} -gt 1 ]
    then
      echo -e "${GREEN}More than one IP. Please type 0 to use the first IP, 1 for the second and so on...${NC}"
      INDEX=0
      for ip in "${NODE_IPS[@]}"
      do
        echo ${INDEX} $ip
        let INDEX=${INDEX}+1
      done
      read -e choose_ip
      NODEIP=${NODE_IPS[$choose_ip]}
  else
    NODEIP=${NODE_IPS[0]}
  fi
}


function compile_error() {
if [ "$?" -gt "0" ];
 then
  echo -e "${RED}Failed to compile $COIN_NAME. Please investigate.${NC}"
  exit 1
fi
}


function prepare_system() {
echo -e "Preparing the VPS to setup. ${CYAN}$COIN_NAME${NC} ${RED}Masternode${NC}"
apt-get update >/dev/null 2>&1
DEBIAN_FRONTEND=noninteractive apt-get update > /dev/null 2>&1
DEBIAN_FRONTEND=noninteractive apt-get -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" -y -qq upgrade >/dev/null 2>&1
apt install -y software-properties-common >/dev/null 2>&1
echo -e "${PURPLE}Adding bitcoin PPA repository"
apt-add-repository -y ppa:bitcoin/bitcoin >/dev/null 2>&1
echo -e "Installing required packages, it may take some time to finish.${NC}"
apt-get update >/dev/null 2>&1
apt-get install -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" make software-properties-common \
build-essential libtool autoconf libssl-dev libboost-dev libboost-chrono-dev libboost-filesystem-dev libboost-program-options-dev \
libboost-system-dev libboost-test-dev libboost-thread-dev automake git wget pwgen curl libdb4.8-dev bsdmainutils libdb4.8++-dev \
libminiupnpc-dev libgmp3-dev ufw pkg-config libevent-dev libdb5.3++ unzip libqt5gui5 libqt5core5a libqt5dbus5 qttools5-dev \
qttools5-dev-tools libprotobuf-dev protobuf-compiler libqrencode-dev libzmq3-dev >/dev/null 2>&1
if [ "$?" -gt "0" ];
  then
    echo -e "${RED}Not all required packages were installed properly. Try to install them manually by running the following commands:${NC}\n"
    echo "apt-get update"
    echo "apt -y install software-properties-common"
    echo "apt-add-repository -y ppa:bitcoin/bitcoin"
    echo "apt-get update"
    echo "apt install -y make build-essential libtool software-properties-common autoconf libssl-dev libboost-dev libboost-chrono-dev libboost-filesystem-dev \
libboost-program-options-dev libboost-system-dev libboost-test-dev libboost-thread-dev automake git pwgen curl libdb4.8-dev \
bsdmainutils libdb4.8++-dev libminiupnpc-dev libgmp3-dev ufw fail2ban pkg-config libevent-dev unzip libqt5gui5 libqt5core5a libqt5dbus5 \
qttools5-dev qttools5-dev-tools libprotobuf-dev protobuf-compiler libqrencode-dev libzmq3-dev"
 exit 1
fi

clear
}

function important_information() {
  echo
  echo -e "${BLUE}================================================================================================================================${NC}"
  echo -e "${PURPLE}Windows Wallet Guide. https://github.com/N8Vcoin/N8Vcoin-Masternode-Script/blob/master/README.md${NC}"
  echo -e "${BLUE}================================================================================================================================${NC}"
  echo -e "$COIN_NAME Masternode is up and running listening on port ${GREEN}$COIN_PORT${NC}."
  echo -e "Configuration file is: ${RED}$CONFIGFOLDER/$CONFIG_FILE${NC}"
  echo -e "Start: ${RED}systemctl start $COIN_NAME.service${NC}"
  echo -e "Stop: ${RED}systemctl stop $COIN_NAME.service${NC}"
  echo -e "VPS_IP:PORT ${GREEN}$NODEIP:$COIN_PORT${NC}"
  echo -e "${GREEN}MASTERNODE GENKEY is:${NC}${PURPLE}$COINKEY${NC}"
  echo -e "${BLUE}================================================================================================================================"
  echo -e "${CYAN}Follow twitter to stay updated.  https://twitter.com/N8Vcoin${NC}"
  echo -e "${BLUE}================================================================================================================================${NC}"
  echo -e "${CYAN}Ensure Node is fully SYNCED with BLOCKCHAIN.${NC}"
  echo -e "${BLUE}================================================================================================================================${NC}"
  echo -e "${GREEN}Usage Commands.${NC}"
  echo -e "${GREEN}$COIN_CLI getmasternodestatus${NC}"
  echo -e "${GREEN}$COIN_CLI getinfo${NC}"
  echo -e "${BLUE}================================================================================================================================${NC}"
 }

function setup_node() {
  get_ip
  create_config
  create_key
  update_config
  enable_firewall
  important_information
  configure_systemd
}

##### Main #####
clear

prepare_system
download_node
setup_node
