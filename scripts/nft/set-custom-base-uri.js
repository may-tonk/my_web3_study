const hre = require("hardhat");

async function main() {
  const contractAddress = process.env.DUTCH_AUCTION_ADDRESS;
  const baseURI = process.env.BASE_URI;

  if (!contractAddress) {
    throw new Error("Missing DUTCH_AUCTION_ADDRESS in environment.");
  }
  if (!baseURI) {
    throw new Error("Missing BASE_URI in environment.");
  }

  const auction = await hre.ethers.getContractAt(
    "contracts/DutchAuction.sol:DutchAuction",
    contractAddress
  );
  const tx = await auction.setBaseURI(baseURI);
  await tx.wait();

  console.log("setBaseURI tx:", tx.hash);
  console.log("baseURI:", baseURI);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
