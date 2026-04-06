const { account1, account2 } = require("../../hlper-hardhat-config")
const { ethers } = require("hardhat");

async function main() {

    const [deploy] = await ethers.getSigners()
    console.log("deploy default firstaccount", deploy.address)

    const origin_chain = "0xddeC2eE0672F9A2bbd65504E997eFB12922307a6"

    const origin = await ethers.getContractAt("CrossChainOrigin", origin_chain)

    const senderaddress = account1
    const receiveaddress = account2

    const amount = ethers.parseEther("8888.0")
    const message = ethers.AbiCoder.defaultAbiCoder().encode(
        ["address", "address", "uint256"],
        [senderaddress, receiveaddress, amount]
    )

    console.log("正在调用trigger()....")
    console.log("发送地址:", senderaddress)
    console.log("接收地址:", receiveaddress)
    console.log("金额:", ethers.formatEther(amount), "REACT")

    const tx = await origin.trigger(message)
    await tx.wait(2)

    console.log("trigger调用成功!")
    console.log("交易哈希:", tx.hash)
    console.log("请等待跨链消息被处理，稍后检查接收地址的余额变化。")



}


main().catch((error) => {
    console.error(error)
    process.exitCode = 1
})




