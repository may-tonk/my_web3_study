const hre = require("hardhat");

async function main() {
  const contractAddress = process.env.DUTCH_AUCTION_ADDRESS;
  const metadataCid = process.env.METADATA_CID;

  if (!contractAddress) {
    throw new Error("Missing DUTCH_AUCTION_ADDRESS in environment.");
  }
  if (!metadataCid) {
    throw new Error("Missing METADATA_CID in environment.");
  }

  const baseURI = `ipfs://${metadataCid}/`;
  const auction = await hre.ethers.getContractAt("DutchAuction", contractAddress);
  const tx = await auction.setBaseURI(baseURI);
  await tx.wait();

  console.log("setBaseURI tx:", tx.hash);
  console.log("baseURI:", baseURI);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
