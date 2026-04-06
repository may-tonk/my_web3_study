const fs = require("fs");
const path = require("path");

const count = Number(process.env.NFT_COUNT || 2);
const imageCid = process.env.IMAGES_CID || "<IMAGES_CID>";
const collectionName = process.env.COLLECTION_NAME || "WTF Dutch Auction";
const description =
  process.env.COLLECTION_DESCRIPTION ||
  "Two-piece test collection for Dutch auction.";

const metadataDir = path.join(__dirname, "..", "..", "nft", "metadata");
fs.mkdirSync(metadataDir, { recursive: true });

for (let i = 0; i < count; i++) {
  const json = {
    name: `${collectionName} #${i}`,
    description,
    image: `ipfs://${imageCid}/${i}.png`,
    attributes: [
      { trait_type: "Edition", value: String(i) },
      { trait_type: "Style", value: "Monochrome" },
    ],
  };

  const filePath = path.join(metadataDir, `${i}.json`);
  fs.writeFileSync(filePath, JSON.stringify(json, null, 2), "utf8");
}

console.log(`Generated ${count} metadata files in ${metadataDir}`);
