const hre = require("hardhat")
const { deployments, ethers, getNamedAccounts } = require("hardhat")
async function main() {
    const name = "hello"
    const symbol = "myfirstERC20"

    // 获取账户地址
    const { firstAccount } = await hre.getNamedAccounts()
    // 使用 ethers 获取 signer 对象
    const deployer = await hre.ethers.getSigner(firstAccount)

    // 获取合约工厂，并指定 signer
    const MyContractFactory = await hre.ethers.getContractFactory("mycontract", deployer)

    // 部署合约
    const myToken = await MyContractFactory.deploy(name, symbol)

    // 等待部署完成
    await myToken.waitForDeployment()

    console.log(`Contract deployed at: ${myToken.target}`)

    // 查询部署者初始余额
    const initialBalance = await myToken.balanceOf(firstAccount)
    console.log("Deployer initial balance:", initialBalance.toString())

    // mint 1000 代币给部署者
    const decimals = 18
    const mintAmount =1000
    await myToken.mint(mintAmount)

    // 查询 mint 后余额
    const newBalance = await myToken.balanceOf(firstAccount)
    console.log("Deployer balance after mint:", hre.ethers.formatUnits(newBalance, decimals))

}

main().catch((error) => {
    console.error(error)
    process.exit(1)
})

