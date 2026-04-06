const { ethers } = require("hardhat")

async function main() {
    const REACTIVE_CONTRACT = "0xf92d6B02aEc7f290B0c7546FF7BAfB993658D211"
    const balance = await ethers.provider.getBalance(REACTIVE_CONTRACT)
    console.log("合约 lREACT 余额:", ethers.formatEther(balance))
}

main().catch((error) => {
    console.error(error)
    process.exitCode = 1
})