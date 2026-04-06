
const   {MailBox_BNB} = require("../../hlper-hardhat-config")
const {ethers} = require("hardhat")
async function main(){

    const[deployer] = await ethers.getSigners()
    console.log("deploy default firstaccount")
    console.log("Deploying contracts with the account:", deployer.address)
    


    console.log("Deploying CrossChainOrigin...")

    const Origin = await ethers.getContractFactory("CrossChainOrigin")

    const origin = await Origin.deploy(MailBox_BNB)

    await origin.waitForDeployment()

    const address = await origin.getAddress()
    console.log("部署success")
    console.log("HyperlaneOrigin deployed to:", address)

}


    main().catch((error)=>{
        console.error(error)
        process.exitCode = 1
    })



