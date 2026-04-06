const hre = require("hardhat");

async function main() {
  const contractAddress = process.env.DUTCH_AUCTION_ADDRESS;
  if (!contractAddress) {
    throw new Error("Missing DUTCH_AUCTION_ADDRESS in environment.");
  }

  const auction = await hre.ethers.getContractAt(
    "contracts/DutchAuction.sol:DutchAuction",
    contractAddress
  );

  const startTime = await auction.auctionStartTime();
  const price = await auction.getAuctionPrice();
  const supply = await auction.totalSupply();

  let token0Uri = "";
  try {
    token0Uri = await auction.tokenURI(0);
  } catch (_) {
    token0Uri = "(tokenId 0 not minted yet)";
  }

  console.log("contract:", contractAddress);
  console.log("auctionStartTime:", startTime.toString());
  console.log("currentPrice(wei):", price.toString());
  console.log("totalSupply:", supply.toString());
  console.log("tokenURI(0):", token0Uri);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
