// hardhat.config.js
const { privateKey, infuraProjectId, mnemonic, apiKey } = require('./secrets.json');
require("@nomiclabs/hardhat-waffle");
require('@nomiclabs/hardhat-ethers');
require("@nomiclabs/hardhat-etherscan");
require('hardhat-deploy');
/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {

  networks: {
    rinkeby: {
      url: `https://rinkeby.infura.io/v3/${infuraProjectId}`,
      accounts: [privateKey]
    },
    ropsten: {
      url: `https://ropsten.infura.io/v3/${infuraProjectId}`,
      accounts: [privateKey]
    },
    kovan: {
      url: `https://kovan.infura.io/v3/${infuraProjectId}`,
      accounts: [privateKey]
    },
    goerli: {
      url: `https://goerli.infura.io/v3/${infuraProjectId}`,
      accounts: [privateKey]
    },
    mainnet: {
      url: `https://mainnet.infura.io/v3/${infuraProjectId}`,
      accounts: [privateKey]
    },
    hardhat: {
      accounts: {
          count: 2001
      }
    },
  },

  etherscan: {
    // Your API key for Etherscan
    // Obtain one at https://etherscan.io/
    apiKey: `${apiKey}`
//    `WRQ5YKJ5K7NXCSYUP1ITC3V7T8HG6EWTKX`
  },
  solidity: "0.8.9"
};
