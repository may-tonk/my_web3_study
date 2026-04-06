// scripts/deploy.js
async function main() {
  const MyToken = await ethers.getContractFactory("MyToken");
  const token = await MyToken.deploy(1000000); // 1M initial supply
  await token.deployed();

  console.log("Token deployed to:", token.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});