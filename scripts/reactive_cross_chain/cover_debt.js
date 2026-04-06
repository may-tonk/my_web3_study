const { ethers } = require("hardhat")

async function main() {
    const [deployer] = await ethers.getSigners()
    console.log("Account:", deployer.address)

    const REACTIVE_CONTRACT = "0xf92d6B02aEc7f290B0c7546FF7BAfB993658D211"
    
    // coverDebt sends REACT tokens to activate the subscription
    const tx = await deployer.sendTransaction({
        to: REACTIVE_CONTRACT,
        value: ethers.parseEther("0.5")  // send 0.1 REACT
    })
    await tx.wait(2)

    console.log("coverDebt success!")
    console.log("Transaction hash:", tx.hash)
}

main().catch((error) => {
    console.error(error)
    process.exitCode = 1
})