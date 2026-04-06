# NFT Asset Flow

1. Put your images into `nft/images/` and rename them as:
   - `0.png`
   - `1.png`
2. Upload `nft/images/` to IPFS and get `IMAGES_CID`.
3. Generate metadata:

```bash
$env:NFT_COUNT=2
$env:IMAGES_CID="<your_images_cid>"
node scripts/nft/generate-metadata.js
```

4. Upload `nft/metadata/` to IPFS and get `METADATA_CID`.
5. Set contract base URI:

```bash
$env:DUTCH_AUCTION_ADDRESS="<your_contract_address>"
$env:METADATA_CID="<your_metadata_cid>"
npx hardhat run scripts/nft/set-base-uri.js --network <your_network>
```

6. Verify:
   - `tokenURI(0)` => `ipfs://<METADATA_CID>/0.json`
   - `tokenURI(1)` => `ipfs://<METADATA_CID>/1.json`

7. Mint by script:

```bash
$env:DUTCH_AUCTION_ADDRESS="<your_contract_address>"
$env:MINT_QUANTITY=1
npx hardhat run scripts/nft/mint-dutch-auction.js --network <your_network>
```

8. Optional: set auction start time:

```bash
$env:DUTCH_AUCTION_ADDRESS="<your_contract_address>"
$env:AUCTION_START_TIME=1760000000
npx hardhat run scripts/nft/set-auction-start-time.js --network <your_network>
```
