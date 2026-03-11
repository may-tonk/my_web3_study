const { ethers } = require("hardhat");

async function main() {
  // ↓ 在这里填写参数
  const CALLBACK_SENDER = "0xc9f36411C9897e7F959D99ffca2a0Ba7ee0D7bDA";  // ← 填这里

  const Callback = await ethers.getContractFactory("BasicDemoL1Callback");
  const contract = await Callback.deploy(
    CALLBACK_SENDER,
    { value: ethers.parseEther("0.01") }  // ← 部署时发送的ETH
  );
  await contract.waitForDeployment(4);

  console.log("BasicDemoL1Callback deployed to:", await contract.getAddress());
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});