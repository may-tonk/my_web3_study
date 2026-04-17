const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("SignatureNFT", function () {
  let ecdsaLib;
  let signatureNFT;
  let deployer;
  let authorizer;
  let user1;
  let user2;
  let relayer;
  let attacker;

  /**
   * 工具函数：生成某个 (account, tokenId) 的有效签名
   *
   * 签名流程与合约保持一致：
   * 1) 先调用合约的 getMessageHash(account, tokenId)
   * 2) 用签名者对该 hash 的 bytes 进行 signMessage
   *
   * 注意：
   * - ethers v6 里 signMessage 要传 bytes，所以要用 ethers.getBytes(hash)
   * - 默认签名人是 authorizer（即合约构造函数里的 signer）
   */
  async function signMintPayload(account, tokenId, signerWallet = authorizer) {
    const messageHash = await signatureNFT.getMessageHash(account, tokenId);
    return signerWallet.signMessage(ethers.getBytes(messageHash));
  }

  beforeEach(async function () {
    // 角色划分：
    // deployer  : 部署者
    // authorizer: 链下授权签名人（合约内 signer）
    // user1/user2: 被授权 mint 的接收者
    // relayer   : 代发交易账号
    // attacker  : 错误签名人，用于负面测试
    [deployer, authorizer, user1, user2, relayer, attacker] = await ethers.getSigners();

    // 1) 先部署 library
    const ECDSAFactory = await ethers.getContractFactory("ECDSA");
    ecdsaLib = await ECDSAFactory.deploy();
    await ecdsaLib.waitForDeployment();

    // 2) 部署主合约时手动链接 library 地址
    const SignatureNFTFactory = await ethers.getContractFactory("SignatureNFT", {
      libraries: {
        ECDSA: await ecdsaLib.getAddress(),
      },
    });

    signatureNFT = await SignatureNFTFactory.deploy(
      "Signature NFT",
      "SNFT",
      authorizer.address
    );
    await signatureNFT.waitForDeployment();
  });

  it("constructor: should set signer correctly", async function () {
    expect(await signatureNFT.signer()).to.equal(authorizer.address);
  });

  it("verify: should return true for a valid signature", async function () {
    const tokenId = 1n;
    const messageHash = await signatureNFT.getMessageHash(user1.address, tokenId);
    const signature = await authorizer.signMessage(ethers.getBytes(messageHash));

    // verify 接收的是 ethSignedMessageHash，不是原始 messageHash
    const ethSignedHash = ethers.hashMessage(ethers.getBytes(messageHash));
    expect(await signatureNFT.verify(ethSignedHash, signature)).to.equal(true);
  });

  it("verify: should return false for signature signed by wrong signer", async function () {
    const tokenId = 1n;
    const messageHash = await signatureNFT.getMessageHash(user1.address, tokenId);
    const badSignature = await attacker.signMessage(ethers.getBytes(messageHash));
    const ethSignedHash = ethers.hashMessage(ethers.getBytes(messageHash));

    expect(await signatureNFT.verify(ethSignedHash, badSignature)).to.equal(false);
  });

  it("mint: relayer can submit tx when signature is valid", async function () {
    const tokenId = 10n;
    const signature = await signMintPayload(user1.address, tokenId);

    // relayer 不是接收者，也不是签名人；只负责代发交易
    await expect(
      signatureNFT.connect(relayer).mint(user1.address, tokenId, signature)
    ).to.not.be.reverted;

    expect(await signatureNFT.ownerOf(tokenId)).to.equal(user1.address);
    expect(await signatureNFT.mintedAddress(user1.address)).to.equal(true);
  });

  it("mint: should revert with Invalid signature for unauthorized signer", async function () {
    const tokenId = 11n;
    const badSignature = await signMintPayload(user1.address, tokenId, attacker);

    await expect(
      signatureNFT.mint(user1.address, tokenId, badSignature)
    ).to.be.revertedWith("Invalid signature");
  });

  it("mint: should revert when the same address tries to mint twice", async function () {
    const firstTokenId = 20n;
    const secondTokenId = 21n;

    const sig1 = await signMintPayload(user1.address, firstTokenId);
    await signatureNFT.mint(user1.address, firstTokenId, sig1);

    // 第二次即使是新的 tokenId、有效签名，也会被 mintedAddress 限制挡住
    const sig2 = await signMintPayload(user1.address, secondTokenId);
    await expect(
      signatureNFT.mint(user1.address, secondTokenId, sig2)
    ).to.be.revertedWith("Already minted!");
  });

  it("mint: should revert for signature length != 65 bytes", async function () {
    const tokenId = 30n;
    const invalidLengthSignature = "0x1234";

    await expect(
      signatureNFT.mint(user1.address, tokenId, invalidLengthSignature)
    ).to.be.revertedWith("invalid signature length");
  });

  it("mint: should revert when tokenId already exists (ERC721 custom error)", async function () {
    const tokenId = 99n;

    const sigForUser1 = await signMintPayload(user1.address, tokenId);
    await signatureNFT.mint(user1.address, tokenId, sigForUser1);

    // user2 是新地址，不触发 Already minted，但 tokenId 已存在，会在 _mint 处失败
    const sigForUser2 = await signMintPayload(user2.address, tokenId);
    await expect(
      signatureNFT.mint(user2.address, tokenId, sigForUser2)
    )
      .to.be.revertedWithCustomError(signatureNFT, "ERC721InvalidSender")
      .withArgs(ethers.ZeroAddress);
  });
});
