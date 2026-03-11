const { ethers } = require("hardhat");

async function main() {
  const [sender] = await ethers.getSigners();

  const L1_CONTRACT = "0x471fE75b1F36F118364b99D7d37B03f7a47d29e9";

  console.log("发送ETH到 L1Contract...");
  const tx = await sender.sendTransaction({
    to: L1_CONTRACT,
    value: ethers.parseEther("0.001"),  // 触发阈值
  });

  await tx.wait();
  console.log("交易哈希:", tx.hash);
  console.log("查看交易:", `https://sepolia.etherscan.io/tx/${tx.hash}`);
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});