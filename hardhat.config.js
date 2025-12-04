require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();
require('hardhat-deploy');
const sepolia_url=process.env.SEPOLIA_URL
const my_key1=process.env.WALLET_KEY1
const MY_API_KEY=process.env.API_KEY
const my_key2=process.env.WALLET_KEY2
/** @type import('hardhat/config').HardhatUserConfig */



/*import{ defineConfig } from "hardhat/config";
import hardhatVerify from "@nomicfoundation/hardhat-verify";*/

/*import { defineConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "@nomicfoundation/hardhat-verify"; */

module.exports = {
  solidity: "0.8.28",
  defaultNetwork:"hardhat",//判断本地网络
  networks:{
    sepolia:{
      url:sepolia_url,//alchemy中的url
      accounts:[my_key1,my_key2],//钱包私钥1,2      可以联系到namedAccount
      chainId:11155111//network ID
    }
  },


    etherscan: {
    
      apiKey:MY_API_KEY//来自https://etherscan.io/apidashboard
      
      
    },

  //主要是用在deploy文件夹
    namedAccounts:{//主要是用在Singner()
      firstAccount:{//用来表示第一个钱包
        default:0
      },
      secondAccount:{//用来表示第二个钱包
        default:1
      }
    }


};
