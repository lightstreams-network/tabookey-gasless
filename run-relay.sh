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

$gobin/RelayHttpServer -DefaultGasPrice 500000000000 -GasPricePercent 0 -RelayHubAddress $hubaddr -RegistrationBlockRate 100 -Workdir $root/build/server
