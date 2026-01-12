#!/usr/bin/env sh

set -e

CURRENT_UID=$(id -u)

TOKEN=${TOKEN}
PORT=${PORT}
EXTERNAL_ADDRESS=${EXTERNAL_ADDRESS}
EXT_ADDRESS_PORT="$EXTERNAL_ADDRESS:$PORT"
PRIVATE=${PRIVATE}
POOLS=${POOLS}

VERSION=$(/usr/bin/strelaysrv -version | awk '{print $2}')

DYNAMIC_PARAMS=""

echo -e "
────────────────────────────────────────
 
          Syncthing Relay Server
           by The Black Wizard
               $VERSION
 
────────────────────────────────────────
\n"

echo "* Set variables..."

if [[ $EXT_ADDRESS_PORT =~ ^:[0-9]+$ ]]; then
  echo "** External address has been set to 0.0.0.0:$PORT!"
else
  IPADDRESS=$(dig $EXTERNAL_ADDRESS -t A +short | grep -v '\.$')
  echo "** External address has been set to $IPADDRESS:$PORT!"
fi

if [[ -z $PRIVATE ]]; then
  echo "** This relay is public!"
fi

if [[ ! -z $PRIVATE ]]; then
  POOLS=""
  echo "** This relay is private!"
fi

if [[ -f "$TOKEN" ]]; then
  echo "** Get Token from secrets"
  TOKEN=$(cat "$TOKEN")
fi

if [[ -n "$NAT" && "$NAT" == "True" ]]; then
  echo "** Enable UPnP/NAT-PMP"
  DYNAMIC_PARAMS="$DYNAMIC_PARAMS -nat"
fi

if [[ -n "$DEBUG" && "$DEBUG" == "True" ]]; then
  echo "** Enable debug output"
  DYNAMIC_PARAMS="$DYNAMIC_PARAMS -debug"
fi

echo -e "\n* Initialization complete!\n"

if [[ $CURRENT_UID -eq 0 ]]; then
  echo "* Run Syncthing Relay as default user (syncrelay (1000:1000))..."
  echo ""
  chown -R syncrelay:syncrelay /var/strelaysrv
  exec su - syncrelay -c 'exec /usr/bin/strelaysrv "$@"' -- -ext-address="$EXT_ADDRESS_PORT" \
    -token="$TOKEN" \
    -pools="$POOLS" \
    "$DYNAMIC_PARAMS"
else
  echo "* Run Syncthing Relay as custom user ($(id -u):$(id -g))..."
  echo ""
  exec /usr/bin/strelaysrv -ext-address="$EXT_ADDRESS_PORT" \
    -token="$TOKEN" \
    -pools="$POOLS" \
    "$DYNAMIC_PARAMS"
fi
