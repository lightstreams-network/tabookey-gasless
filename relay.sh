#!/bin/bash -e

dir=`dirname $0`
root=`cd $dir;pwd`
gobin=$root/build/server/bin/

function init_relay() {
    echo "Configurable networks: 'standalone','sirius','mainnet'"

    if [ "${NETWORK}" != "standalone" ] && [ "${NETWORK}" != "sirius" ] && [ "${NETWORK}" != "mainnet" ]; then
		echo "Invalid network: ${NETWORK}"
		exit 1
    else
		echo "Using network: ${NETWORK}"
    fi

    network=${NETWORK}

    cd $root

    export GOPATH=$root/server/:$root/build/server
    echo "GOPATH: $GOPATH"
    echo "RELAY_URL: ${RELAY_URL}"

    ./scripts/extract_abi.js

    blocktime=${T=0}

    hubaddr=`npx truffle migrate --network=$network --reset | tee /dev/stderr | grep -A 4 "RelayHub" | grep "contract address" | grep "0x.*" -o`

    if [ -z "$hubaddr" ]; then
	echo "FATAL: failed to detect RelayHub address"
	exit 1
    fi

    echo $hubaddr > ./hubaddr.txt

    ( sleep 3; ./scripts/fundrelay.js $hubaddr ${RELAY_URL} 0 ) &
}

function run_relay() {
    hubaddr=$(cat ${root}/hubaddr.txt)
    $gobin/RelayHttpServer -DefaultGasPrice ${GAS_PRICE} -GasPricePercent ${GAS_PRICE_PERCENT} -RelayHubAddress $hubaddr -RegistrationBlockRate ${REGISTRATION_BLOCK_RATE} -Workdir $root/build/server -EthereumNodeUrl ${ETHEREUM_NODE_URL} -Url http://localhost:8090
}

function main() {
    if [ ! -f $root/hubaddr.txt ]; then
	init_relay
    fi
    run_relay
}

main
