#!/bin/bash -e

dir=`dirname $0`
root=`cd $dir;pwd`
gobin=$root/build/server/bin/

function init_relay() {
    echo "Configurable networks: 'standalone','sirius','mainnet'"

    if [ "$1" != "standalone" ] && [ "$1" != "sirius" ] && [ "$1" != "mainnet" ]; then
	echo "Invalid network: $1"
	exit 1
    else
	echo "Using network: $1"
    fi

    network=$1

    cd $root

    export GOPATH=$root/server/:$root/build/server
    echo "Using GOPATH=$GOPATH"

    ./scripts/extract_abi.js
    make -C server

    blocktime=${T=0}

    hubaddr=`npx truffle migrate --network=$network --reset | tee /dev/stderr | grep -A 4 "RelayHub" | grep "contract address" | grep "0x.*" -o`

    if [ -z "$hubaddr" ]; then
	echo "FATAL: failed to detect RelayHub address"
	exit 1
    fi

    echo $hubaddr > ./hubaddr.txt

    relayurl=http://localhost:8090
    ( sleep 1 ; ./scripts/fundrelay.js $hubaddr $relayurl 0 )
}

function run_relay() {
    hubaddr=$(cat ${root}/hubaddr.txt)
    $gobin/RelayHttpServer -DefaultGasPrice 500000000000 -GasPricePercent 0 -RelayHubAddress $hubaddr -RegistrationBlockRate 100 -Workdir $root/build/server
}

function main() {
    if [ ! -f $root/hubaddr.txt ]; then
	init_relay $@
    fi
    run_relay
}

main $@
