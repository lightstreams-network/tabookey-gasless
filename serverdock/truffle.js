module.exports = {
  networks: {
    devUseHardcodedAddress: {
      verbose: process.env.VERBOSE,
        host: "host.docker.internal",
        port: 8545,
        network_id: "*",
        from: "0x8f337bf484b2fc75e4b0436645dcc226ee2ac531"
      },
      devUseHardcodedAddressLocal: {
      verbose: process.env.VERBOSE,
        host: "127.0.0.1",
        port: 8545,
        network_id: "*",
        from: "0x8f337bf484b2fc75e4b0436645dcc226ee2ac531"
      },
      standalone: {
      verbose: process.env.VERBOSE,
        host: "127.0.0.1",
        port: 8545,
        network_id: "*",
        from: "0xc916cfe5c83dd4fc3c3b0bf2ec2d4e401782875e"
      },
  },
  mocha: {
      slow: 1000
  },
  compilers: {
    solc: {
      version: "0.5.10",
    }
  }

};
