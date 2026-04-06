const hre = require("hardhat");

async function main() {
  const contractAddress = process.env.DUTCH_AUCTION_ADDRESS;
  const quantity = Number(process.env.MINT_QUANTITY || 1);

  if (!contractAddress) {
    throw new Error("Missing DUTCH_AUCTION_ADDRESS in environment.");
  }
  if (!Number.isInteger(quantity) || quantity <= 0) {
    throw new Error("MINT_QUANTITY must be a positive integer.");
  }

  const auction = await hre.ethers.getContractAt(
    "contracts/DutchAuction.sol:DutchAuction",
    contractAddress
  );

  const unitPrice = await auction.getAuctionPrice();
  const totalCost = unitPrice * BigInt(quantity);

  console.log("contract:", contractAddress);
  console.log("unitPrice(wei):", unitPrice.toString());
  console.log("quantity:", quantity);
  console.log("totalCost(wei):", totalCost.toString());

  const tx = await auction.auctionMint(quantity, { value: totalCost });
  await tx.wait();

  console.log("mint tx:", tx.hash);
  console.log("totalSupply:", (await auction.totalSupply()).toString());
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
