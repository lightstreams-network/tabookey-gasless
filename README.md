# Tabookey Relay Network

## What is it?

It's a mechanism for dApps to work with gas-less clients.
Users are no longer required to install browser extensions, or buy Ether in order to use the dApp. 

The dApp owner decides which clients or what calls are allowed, and pays for the calls. It may use its own mechanism to manage its users.

Examples

- Allow first-time install of an app, before the user buys any ether.
- Allow users to pay for transactions with their credit cards and manage their credit.
- For enterprise: trust employees to access the enterprise dApp. 

Its very simple to adapt an existing contract and apps to use the Relays

## How it works?

For a full techincal description, see our [EIP draft](https://github.com/yoav-tabookey/EIPs/blob/master/EIPS/eip-1613.md)

The client has an account (address and private key) just like any other ethereum account - except that it never has to have any money in it.
It makes an off-chain request to a Relay Service, outside of the ethereum network.
The relay transfers the request to the target contract (through a public RelayHub contract)
The relay gets **compensated** by the target contract for its effort.

## Do I need Metamask/Mist/Hardware wallet ?

Since clients no longer carry ether, you're not *required* to use strong wallet - you can keep the client's private key
is a local file (cookie). 
By default, the client library will attempt to use an account known by your local web3.
You can override this behaviour, by providing your own signing function configuration parameter.

## Is it safe?

Absolutely.
In our "mutual-distrust" model, neither the client or contract has to trust the relay to work correctly, nor the relay trusts the contract or client.
All transaction are signed, both by the client (though its account doesn't have to carry any ether) and by the relay.

- The contract knows that only trusted requests will ever be relayed to it, and that it's only liable to pay for those.
- The relay can be sure it will be compensated by the contract for its service.
- The client can be sure the relay did its job to relay the request, and didn't try to fool either the client or contract.
- The Relay, even though its an off-chain component, is not trusted in any way, and can't DoS the system or steal funds. Any such attempt is cryptographically proven, and penalizes the relay before banning it from the network.

Neither the relays in the network, nor the RelayHub contract are controlled by Tabookey in any way. 
We will operate relays in the network, to make sure there's availability of relays, but so can anyone else. 
The relays network is a free market, where relays compete based on transaction fees and quality of service, on equal grounds.

## Usage:

Prerequisites:

-	node, npm
- 	truffle
-	docker

Install node pakcages:

	npm install

Compile and run tests:

	./dock/run.sh npm test

The above is a docker wrapper, containing build prerequisites (`go`, `abigen`, `solc`). If you have them installed, you can run instead:

	npm test

### Running a web client

Here's how to download and run our modified "MetaToken", modified to demonstrate supoprt for gasless transaction.
In the tabookey-gasless folder do:

	./dock/run.sh ./restart-relay.sh web

Configure your MetaMask to Localhost:8545
open your browser to `http://localhost:8080/`

Notes

- The app was modified to give initial 10000 META for every account.
- Once you enter an amount and hit "transfer", a metamask "SIGN" dialog would appear.
- After successful transaction, the amount of META tokens left is updated, to signify the transaction succeeded.
- Restarting the `restart-relay.sh` script will kill ganache, so you must run `truffle migrate && truffle test` again
	in the `webpack-box project`, to re-deploy the MetaCoin, and fund it with initial ether 
	(remember: it's the contract that pays for transactions, not the webapp!)
- MetaMask gets confused after node restart, so switch to another network (e.g. mainnet) and back to localhost.


### Compoments:

- **RelayHub** - master contract on the blockchain, to manage all relays, and help clients find them.
- **RelayServer** - a relay service daemon, running as a geth module or standalone HTTP service.  Advertises itself (through the RelayHub) and waits for client requests.
- **RelayClient** - a javascript library for a client to access the blockchain through a relay.
	Provides APIs to find a good relay, and to send transactions through it.
	The library hooks the local web3, so that any loaded contract API will go through the relay.

note that `npm test` above runs the entire suite: it compiles the server, then launches *ganache-cli* node, deploys the needed component and starts the relay server. then it launches truffle test to run the client tests against the relay server and the contracts on the blockchain.

### Client modifications.


	RelayClient = require( 'relayclient')
	relayclient = new RelayClient({})

	MyContract = web3.contract(...)
	relayclient.hook(MyContract)

	//from now on, any request through this contract will go through a relay
	myContract = MyContract.at('...')
	myContract.someMethod()

	//You can also hook web3 itself, so that any accessed contract will go through a relay.

#### RelayClient options:

A relay client can receive various options:

- `relayHubAddress` - use a specific relay hub. Currently this option is required, since there's not yet a final relay hub deployed.
- `relayUrl`, `relayAddress` - instead of searching for an available relay, you may specify a specific relay to use.

### Contract modifications

In order to support relayed trasnactions, the contract must implement the `RelayRecipient` contract. This way it can check (before the call) the caller, and decide whether to accept the call.

Here's a basic contract, which accepts requests from known users.

	contract MyContract is RelayRecipient {
		constructor() {
			// this is the only hub I trust to receive calls from
			init_relay_hub(RelayHub(0xe78A0F7E598Cc8b0Bb87894B0F60dD2a88d6a8Ab));
		}

	    mapping (address => bool) public my_users;

		// this method is called by the RelayHub, before relaying the transaction.
		// the method should return zero if and only if the contract accepts this transaction, and is willing to pay
		// the relay for its service.
		// it can check the user, the relay or the actual function call data.
		// note that when the RelayHub calls this method, its after it did validation of the relay and caller signatures.
		function may_relay(address relay, address from, bytes /* transaction */) public view returns(uint32) {

			// we simply trust all our known users.
	        if ( !my_users[from] ) return 10;
        	return 0;
	    }

	    // note that when receiving a request from a relay, the msg.sender is always a RelayHub.
	    // You must change your contract to use get_sender() to get the real sender.
	    // (its OK if someone calls this method directly: if no relay is involved, get_sender() returns msg.sender)
	    function my_method() {
	    	require ( my_users[ get_sender() ] );
	    	...
	    }
	}

In the *contracts/recipients* there are several sample RelayRecipient implementations for general use-cases.
