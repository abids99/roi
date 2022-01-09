require('babel-register');
require('babel-polyfill');
require('dotenv').config();
const HDWalletProvider = require("@truffle/hdwallet-provider")
const privateKeys = process.env.PRIVATE_KEYS || ""
const privateKeysMatic = process.env.PRIVATE_KEYS_MATIC || ""
const fs = require('fs');
const mnemonic = fs.readFileSync(".secret").toString().trim();
const BSCSCANAPIKEY = 'GHYUP1C31GVQK6PFZ1WRHPGUW6IH2V182G'
module.exports = {
  
  plugins: [
    'truffle-plugin-verify'
  ],
  api_keys: {
    bscscan: BSCSCANAPIKEY
  },

  networks: {
    development: {
      host: '127.0.0.1',
      port: 8545,
      // port: 7545,
      network_id: "*" // Match any network id
    },
    bsctestnet: {
      provider: () => new HDWalletProvider(mnemonic, `https://data-seed-prebsc-1-s1.binance.org:8545`),
      network_id: 97,
      confirmations: 10,
      timeoutBlocks: 200,
      skipDryRun: true
    },
    ropsten: {
      provider: function() {
        return new HDWalletProvider(
          privateKeys.split(','), // Array of account private keys
          `https://ropsten.infura.io/v3/${process.env.INFURA_API_KEY}`
        )
      },
      gas: 5000000,
      gasPrice: 25000000000,
      network_id: 3
    },
    matic: {
      provider: () => new HDWalletProvider([privateKeysMatic], `https://rpc-mumbai.maticvigil.com/v1/${process.env.MATIC_NODE}`),
      network_id: 80001,
      confirmations: 2,
      timeoutBlock: 200,
      skipDryRun: true,
    }
  },
  contracts_directory: './src/contracts/',
  contracts_build_directory: './src/abis/',
  compilers: {
    solc: {
      version: "0.8.0",
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  }
}