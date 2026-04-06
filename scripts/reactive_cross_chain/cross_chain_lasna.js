const {Mail_Box_LASNA, MailBox_BNB} = require("../../hlper-hardhat-config")
const {ethers} = require("hardhat")
async function main(){
    const[deployer] = await ethers.getSigners()

    console.log("deploy default firstaccount")

    console.log("Deploying contracts with the account:", deployer.address)

    const origin_chain_id = 97
    const origin_address = "0xddeC2eE0672F9A2bbd65504E997eFB12922307a6"

    const reactive = await ethers.getContractFactory("CrossChainReactive")
    const reactive_contract = await reactive.deploy(
        Mail_Box_LASNA,
        origin_chain_id,
        origin_address,
        {value: ethers.parseEther("0.1")}

    )

    await reactive_contract.waitForDeployment()

    const address = await reactive_contract.getAddress()

    console.log("部署success")
    console.log("CrossChainReactive deployed to:", address)

    const balance = await ethers.provider.getBalance(address)
    console.log("合约余额:", ethers.formatEther(balance), "lREACT")


}

    main().catch((error)=>{
        console.log(error)
        process.exitCode = 1

    })
    
