const hre = require("hardhat");

// 把环境变量里的 tokenId 转成 BigInt。
// Solidity 的 uint256 在 JS 里推荐用 BigInt 处理，避免 Number 精度问题。
function parseTokenId(rawValue) {
  if (!rawValue) return 1n;
  try {
    return BigInt(rawValue);
  } catch (error) {
    throw new Error(`Invalid TOKEN_ID: ${rawValue}`);
  }
}

async function main() {
  const { ethers } = hre;

  // 默认取 4 个账号，分别扮演：
  // deployer  : 部署者（部署 library + NFT）
  // authorizer: 链下签名者（合约构造参数 signer）
  // recipient : NFT 接收者
  // relayer   : 代发交易者（证明 mint 不依赖 msg.sender）
  const [deployer, authorizer, defaultRecipient, relayer] = await ethers.getSigners();

  // 允许你在命令行通过环境变量覆盖：
  // TOKEN_ID=5 MINT_TO=0xabc... npx hardhat run ... 
  const tokenId = parseTokenId(process.env.TOKEN_ID);
  const recipient = process.env.MINT_TO || defaultRecipient.address;

  // 1) 先部署 ECDSA 库
  // 你的 SignatureNFT 因为调用了 library 的 public 函数，需要手动链接库地址。
  const ECDSAFactory = await ethers.getContractFactory("ECDSA");
  const ecdsaLib = await ECDSAFactory.deploy();
  await ecdsaLib.waitForDeployment();
  const ecdsaLibAddress = await ecdsaLib.getAddress();

  // 2) 部署 SignatureNFT，并在 getContractFactory 里显式指定 libraries。
  const SignatureNFTFactory = await ethers.getContractFactory("SignatureNFT", {
    libraries: {
      ECDSA: ecdsaLibAddress,
    },
  });

  const signatureNFT = await SignatureNFTFactory.deploy(
    "Signature NFT",
    "SNFT",
    authorizer.address
  );
  await signatureNFT.waitForDeployment();
  const nftAddress = await signatureNFT.getAddress();

  // 3) 生成链下签名：
  // 合约内部签名原文是 keccak256(abi.encodePacked(account, tokenId))
  // 然后再套上 Ethereum Signed Message 前缀进行验签。
  const messageHash = await signatureNFT.getMessageHash(recipient, tokenId);
  const signature = await authorizer.signMessage(ethers.getBytes(messageHash));

  // 4) 由 relayer 发起 mint，验证“签名授权 + 代发交易”流程。
  const tx = await signatureNFT.connect(relayer).mint(recipient, tokenId, signature);
  await tx.wait();

  // 5) 输出关键结果，方便你后续接前端或后端服务。
  console.log("deployer:", deployer.address);
  console.log("authorizer(signer):", authorizer.address);
  console.log("recipient:", recipient);
  console.log("relayer:", relayer.address);
  console.log("ECDSA library:", ecdsaLibAddress);
  console.log("SignatureNFT:", nftAddress);
  console.log("tokenId:", tokenId.toString());
  console.log("ownerOf(tokenId):", await signatureNFT.ownerOf(tokenId));
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
