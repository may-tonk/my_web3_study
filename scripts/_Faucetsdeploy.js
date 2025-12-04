// scripts/deployFaucets.js
const hre = require("hardhat");

async function main() {
  // 获取部署账户（默认为 Hardhat 默认第一个账户）
  const [deployer] = await hre.ethers.getSigners();
  console.log("Deploying contracts with account:", deployer.address);

  // 假设已经有一个 ERC20 token 合约部署完成
  // 替换为你的 ERC20 token 地址
  const tokenAddress = "0xd9145CCE52D386f254917e481eB44e9943F39138";

  // 设置每次领取数量和冷却时间
  // 注意：amountAllowed 要乘以 token decimals，比如 18 decimals
  const amountAllowed = hre.ethers.utils.parseUnits("100", 18); // 100 token
  const cooldown = 60; // 60秒冷却时间，测试用

  // 获取 Faucets 合约工厂
  const Faucets = await hre.ethers.getContractFactory("Faucets");

  // 部署合约
  const faucets = await Faucets.deploy(tokenAddress, amountAllowed, cooldown);
  await faucets.deployed();

  console.log("Faucets deployed to:", faucets.address);

  // 查看 owner 是否正确
  const owner = await faucets.owner();
  console.log("Owner is:", owner);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
