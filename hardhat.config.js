require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();
const sepolia_url=process.env.SEPOLIA_URL
const my_key=process.env.WALLET_KEY
const MY_API_KEY=process.env.API_KEY
/** @type import('hardhat/config').HardhatUserConfig */



/*import{ defineConfig } from "hardhat/config";
import hardhatVerify from "@nomicfoundation/hardhat-verify";*/

/*import { defineConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "@nomicfoundation/hardhat-verify"; */

module.exports = {
  solidity: "0.8.28",
  networks:{
    sepolia:{
      url:sepolia_url,
      accounts:[my_key],
      chainId:11155111
    }
  },

    etherscan: {
    
      apiKey:MY_API_KEY
      
      
    }


};
