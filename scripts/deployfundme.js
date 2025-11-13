import hre from "hardhat";

async function main() {
  const FundMe = await hre.ethers.getContractFactory("fundme"); // 注意大小写
  const fundMe = await FundMe.deploy(); // 无参数
  

  await fundMe.waitForDeployment(); // 等待部署完成

  console.log("✅ Contract deployed at:", fundMe.target);
  console.log(`this is deploy successfully${fundMe.target}`)

    if(hre.network.config.chainId==11155111 && process.env.API_KEY){

    console.log(`now please wait!,need four block`)
    await fundMe.deploymentTransaction().wait(4)//等待区块时间 4个区块
    

    await hre.run("verify:verify",
        {
        address:fundMe.target
        //constructorArgs: ["Constructor argument 1"]

        });
    }
    else{
        console.log(`this error: not exist sepolia or other testnetwork`)
    }



}



main().catch((error) => {
  console.error(error);
  process.exit(1);
});