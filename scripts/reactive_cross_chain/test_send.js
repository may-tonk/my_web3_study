const { ethers } = require("hardhat")

async function main() {
    const [deployer] = await ethers.getSigners()
    console.log("调用账户:", deployer.address)

    const REACTIVE_CONTRACT = "0xf92d6B02aEc7f290B0c7546FF7BAfB993658D211"
    const reactive = await ethers.getContractAt("CrossChainReactive", REACTIVE_CONTRACT)

    // 准备和 trigger 一样的 message
    const senderAddr   = "0x03821460938885DCDBe111236A2da58607aB276D"
    const receiverAddr = "0xC28c19E6081cCdcF94680662FeD408d1BF7D8c71"
    const amount       = ethers.parseEther("8888.0")

    const message = ethers.AbiCoder.defaultAbiCoder().encode(
        ["address", "address", "uint256"],
        [senderAddr, receiverAddr, amount]
    )

    console.log("直接调用 send() 测试 Hyperlane 通道...")
    const tx = await reactive.send(message)
    await tx.wait(2)

    console.log("send() 调用成功!")
    console.log("交易 hash:", tx.hash)
    console.log("去 BSCScan 查看 handle() 有没有被触发!")
}

main().catch((error) => {
    console.error(error)
    process.exitCode = 1
})