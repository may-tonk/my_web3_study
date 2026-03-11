const { ethers } = require("hardhat");

async function main() {
  // ↓ 在这里填写所有参数
  const SERVICE_ADDRESS    = "0x0000000000000000000000000000000000fffFfF";           // Reactive Network提供
  const ORIGIN_CHAIN_ID    = 11155111;                  // 监听的链ID（如Sepolia）
  const DEST_CHAIN_ID      = 11155111;                  // 回调目标链ID
  const MONITORED_CONTRACT = "0x471fE75b1F36F118364b99D7d37B03f7a47d29e9";        // L1Contract地址
  const TOPIC_0            = ethers.id("Received(address,address,uint256)"); // 监听的事件签名
  const CALLBACK_ADDRESS   = "0xfacA7AfD6289585c9248530a5BA46182c803c52E";     // L1Callback地址

  const Reactive = await ethers.getContractFactory("BasicDemoReactiveContract");
  const contract = await Reactive.deploy(
    SERVICE_ADDRESS,
    ORIGIN_CHAIN_ID,
    DEST_CHAIN_ID,
    MONITORED_CONTRACT,
    TOPIC_0,
    CALLBACK_ADDRESS,
    { value: ethers.parseEther("0.001") }  // ← 部署时发送的ETH
  );
  await contract.waitForDeployment(4);

  console.log("BasicDemoReactiveContract deployed to:", await contract.getAddress());
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});