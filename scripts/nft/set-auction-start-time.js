const hre = require("hardhat");

async function main() {
  const contractAddress = process.env.DUTCH_AUCTION_ADDRESS;
  const startTime = Number(process.env.AUCTION_START_TIME);

  if (!contractAddress) {
    throw new Error("Missing DUTCH_AUCTION_ADDRESS in environment.");
  }
  if (!Number.isInteger(startTime) || startTime <= 0) {
    throw new Error("AUCTION_START_TIME must be a unix timestamp in seconds.");
  }

  const auction = await hre.ethers.getContractAt(
    "contracts/DutchAuction.sol:DutchAuction",
    contractAddress
  );

  const tx = await auction.setAuctionStartTime(startTime);
  await tx.wait();

  console.log("setAuctionStartTime tx:", tx.hash);
  console.log("auctionStartTime:", startTime);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
