require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();
require("hardhat-deploy");

// 读取环境变量
const sepolia_url = process.env.SEPOLIA_URL;
const my_key1 = process.env.WALLET_KEY1;
const my_key2 = process.env.WALLET_KEY2;
const MY_API_KEY = process.env.API_KEY;

/** @type import('hardhat/config').HardhatUserConfig */

module.exports = {
  solidity: "0.8.28",

  defaultNetwork: "hardhat",

  networks: {
    sepolia: {
      url: sepolia_url,
      accounts: [my_key1, my_key2],
      chainId: 11155111
    },

      "cancun": {
    url: "https://evmrpc-testnet.0g.ai",
    chainId: 16602,
    accounts: [my_key1, my_key2],
    gas: "auto",
    gasPrice: "auto",
  },
     lasna: {
    url: "https://lasna-rpc.rnk.dev/",
    accounts: [my_key1, my_key2],
    chainId: 5318007,
    gas: "auto",
    gasPrice: "auto",
  },
     // BNB Smart Chain Testnet
    bscTestnet: {
      url: "https://data-seed-prebsc-1-s1.bnbchain.org:8545",
      chainId: 97,
      accounts: [my_key1, my_key2],
      gas: "auto",
    },


  },

  etherscan: {
    apiKey: MY_API_KEY
  },

  namedAccounts: {
    firstAccount: {
      default: 0
    },
    secondAccount: {
      default: 1
    },
  }
};