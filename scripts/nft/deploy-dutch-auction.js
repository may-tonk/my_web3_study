const hre = require("hardhat");

async function main() {
  const factory = await hre.ethers.getContractFactory(
    "contracts/DutchAuction.sol:DutchAuction"
  );

  const auction = await factory.deploy();
  await auction.waitForDeployment();

  const address = await auction.getAddress();
  console.log("DutchAuction deployed:", address);

  const metadataCid = process.env.METADATA_CID;
  if (metadataCid) {
    const baseURI = `ipfs://${metadataCid}/`;
    const tx = await auction.setBaseURI(baseURI);
    await tx.wait();
    console.log("setBaseURI tx:", tx.hash);
    console.log("baseURI:", baseURI);
  } else {
    console.log("METADATA_CID not set, skipped setBaseURI.");
  }

  const startTime = process.env.AUCTION_START_TIME;
  if (startTime) {
    const tx = await auction.setAuctionStartTime(Number(startTime));
    await tx.wait();
    console.log("setAuctionStartTime tx:", tx.hash);
    console.log("auctionStartTime:", startTime);
  } else {
    console.log("AUCTION_START_TIME not set, using constructor start time.");
  }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
