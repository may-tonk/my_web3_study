const her = require("hardhat")

async function main(){
    const deploycontract = await her.ethers.getContractFactory("initvalue")

    const mycontract = await deploycontract.deploy()

    await mycontract.waitForDeployment()

    console.log(`successful${mycontract.target}`)

}


main().catch((error)=> {
    console.error(error)
    process.exitCode = 1
})

