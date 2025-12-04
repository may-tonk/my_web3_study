const hre = require("hardhat")
const { developmentChain, networkConfig } = require("../hlper-hardhat-config")

async function main() {

      // 声明变量，用于存储数据源地址
      let dataFeedAddr
      let datafeedadd
  
      // 判断当前网络是否为本地开发网络
      if (developmentChain.includes(network.name)) {
          // 如果是本地网络，获取 MockV3Aggregator 的部署信息
            dataFeedAddr = await deployments.get("MockV3Aggregator")
  
          // 将 MockV3Aggregator 的地址赋值给 datafeedadd，用于 FundMe 合约构造函数
            datafeedadd = dataFeedAddr.address;
      } else {
          // 如果是测试网或主网，从 networkConfig 中获取对应链的 Chainlink 数据源地址
          datafeedadd = networkConfig[network.config.chainId].ethUsdDataFeed
      }
  
  const FundMe = await hre.ethers.getContractFactory("fundme")// 注意大小写
  const fundMe = await FundMe.deploy(datafeedadd)
  

  await fundMe.waitForDeployment() // 等待部署完成

  await fundMe.deploymentTransaction().wait(4);

  console.log("⛓ 已等待 4 个区块确认");

  console.log("✅ Contract deployed at:", fundMe.target)
  console.log(`this is deploy successfully${fundMe.target}`)

    if(hre.network.config.chainId==11155111 && process.env.API_KEY){

    console.log(`now please wait!,need four block`)
    await fundMe.deploymentTransaction().wait(4)//等待区块时间 4个区块
    

    await hre.run("verify:verify",
        {
          address: fundMe.target,
          constructorArguments: [datafeedadd],
        })
    }
    else{
        console.log(`this error: not exist sepolia or other testnetwork`)
    }



}



main().catch((error) => {
  console.error(error)
  process.exit(1)
})