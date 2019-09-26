require('dotenv').config({ path: `${process.env.PWD}/.env` });

const extractEnvAccountAndPwd = (network) => {
  if (network === "sirius") {
    return {
      from: process.env.SIRIUS_ACCOUNT,
      pwd: process.env.SIRIUS_PASSPHRASE
    }
  }
  if (network === "standalone") {
    return {
      from: process.env.STANDALONE_ACCOUNT,
      pwd: process.env.STANDALONE_PASSPHRASE
    }
  }

  if (network === "mainnet") {
    return {
      from: process.env.MAINNET_ACCOUNT,
      pwd: process.env.MAINNET_PASSPHRASE
    }
  }

  console.error("unknown network " + network);
  throw Error("undefined network to deploy to");
};

module.exports = (deployer) => {
  process.env.NETWORK = deployer.network;
  const { from, pwd } = extractEnvAccountAndPwd(deployer.network);

  deployer.then(function() {
    return web3.eth.personal.unlockAccount(from, pwd, 1000)
      .then(console.log('Account unlocked!'))
      .catch((err) => {
        console.log(err);
      });
  });
};
