const her = require("hardhat")

async function main(){
    const deploycontract = await her.ethers.getContractFactory("initvalue")//获取合约

    const mycontract = await deploycontract.deploy()//部署合约

    await mycontract.waitForDeployment()//等待合约部署

    console.log(`successful${mycontract.target}`)//打印合约地址方便查询

}


main().catch((error)=> {//错误捕捉
    console.error(error)
    process.exitCode = 1
})

