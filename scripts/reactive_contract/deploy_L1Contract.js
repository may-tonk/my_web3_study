const { ethers } = require("hardhat");

async function main() {
  // BasicDemoL1Contract 不需要构造参数
  const Contract = await ethers.getContractFactory("BasicDemoL1Contract");
  const contract = await Contract.deploy();
  await contract.waitForDeployment();

  console.log("BasicDemoL1Contract deployed to:", await contract.getAddress());
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});