const her = require("hardhat");


async function main(){
     const Mycontract = await her.ethers.getContractFactory("eventTest");//获取合约

     const mycontract = await Mycontract.deploy();//部署

     await mycontract.waitForDeployment()//等待部署完成

     console.log(`this is contract address ${mycontract.target}`)


}

main().catch((error)=>{
    console.error(error);
    process.exit(1);

});