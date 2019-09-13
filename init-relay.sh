#!/bin/bash -e

echo "Configurable networks: 'standalone','sirius','mainnet'"

if [ "$1" != "standalone" ] && [ "$1" != "sirius" ] && [ "$1" != "mainnet" ]; then
    echo "Invalid network: $1"
else
    echo "Using network: $1"
fi

network=$1

function onexit() {
	echo onexit
	pkill -f RelayHttpServer
}

trap onexit EXIT

dir=`dirname $0`
root=`cd $dir;pwd`

cd $root

gobin=$root/build/server/bin/
export GOPATH=$root/server/:$root/build/server
echo "Using GOPATH=" $GOPATH

./scripts/extract_abi.js
make -C server

blocktime=${T=0}

pkill -f RelayHttpServer && echo kill old relayserver

hubaddr=`npx truffle migrate --network=$network --reset | tee /dev/stderr | grep -A 4 "RelayHub" | grep "contract address" | grep "0x.*" -o`

if [ -z "$hubaddr" ]; then
echo "FATAL: failed to detect RelayHub address"
exit 1
fi

echo $hubaddr

#fund relay:
relayurl=http://localhost:8090
( sleep 1 ; ./scripts/fundrelay.js $hubaddr $relayurl 0 )
