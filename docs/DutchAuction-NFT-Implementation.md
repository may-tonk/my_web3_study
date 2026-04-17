# DutchAuction NFT 项目实现说明

## 1. 项目目标

本项目实现了一个基于 **ERC-721** 的 NFT 荷兰拍卖合约，支持：

- 按时间递减价格（Dutch Auction）
- 用户支付 ETH 进行 `auctionMint`
- 设置 `baseURI`，让钱包/区块浏览器读取 NFT 元数据与图片
- 在 Sepolia 测试网完成部署、铸造与展示验证

---

## 2. 技术选型与原因

### 2.1 区块链与开发框架

- **Solidity (`^0.8.20`)**
  - 原生编写智能合约，适配 EVM。
- **Hardhat**
  - 负责编译、部署、脚本执行与测试，开发效率高。
- **Ethers.js（Hardhat 内置）**
  - 用于脚本和链上交互（部署、调用、读取状态）。
- **OpenZeppelin Contracts**
  - 复用标准 `ERC721` 与 `Ownable`，降低实现风险。

### 2.2 存储与资源分发

- **IPFS（通过 Pinata 上传）**
  - 图片与 metadata 去中心化存储，不依赖单点服务器。
  - 使用 CID 保证内容可验证、不可篡改。

### 2.3 网络与验证工具

- **Sepolia 测试网**
  - 低成本验证部署与铸造流程。
- **Sepolia Etherscan**
  - 查看交易、合约状态、NFT 展示情况。

---

## 3. 核心合约设计

合约文件：`contracts/DutchAuction.sol`

核心逻辑：

1. **价格模型**
   - `AUCTION_START_PRICE` 起拍价
   - `AUCTION_END_PRICE` 底价
   - `AUCTION_TIME` 拍卖总时长
   - `AUCTION_DROP_INTERVAL` 降价间隔
   - `getAuctionPrice()` 动态计算当前价格

2. **铸造逻辑**
   - `auctionMint(quantity)` 检查：
     - 开拍时间
     - 供应量上限
     - 用户支付金额
   - 成功后按数量 mint 并记录总量

3. **元数据入口**
   - `setBaseURI(...)` 由管理员设置 metadata 根路径
   - 重写 `tokenURI(tokenId)`，拼接为：
     - `baseURI + tokenId + ".json"`

---

## 4. 项目实施步骤（含原因）

## 4.1 准备图片资源

目录：

- `nft/images/0.png`
- `nft/images/1.png`

为什么这样做：

- tokenId 与文件名一一对应，后续 metadata 与 `tokenURI` 映射更稳定。

## 4.2 上传图片到 IPFS，获取 `IMAGES_CID`

通过 Pinata 使用 `Folder Upload` 上传 `nft/images` 文件夹。

为什么要文件夹上传：

- 可固定目录结构，生成路径：
  - `ipfs://IMAGES_CID/0.png`
  - `ipfs://IMAGES_CID/1.png`

## 4.3 生成 metadata

脚本：`scripts/nft/generate-metadata.js`

执行：

```powershell
cd e:\Myhardhat\hardhat-test
$env:NFT_COUNT=2
$env:IMAGES_CID="<your_images_cid>"
node scripts/nft/generate-metadata.js
```

生成结果：

- `nft/metadata/0.json`
- `nft/metadata/1.json`

为什么要脚本化：

- 避免手工改 JSON 出错，后续扩展到上千个 NFT 时同样适用。

## 4.4 上传 metadata 到 IPFS，获取 `METADATA_CID`

通过 Pinata 上传 `nft/metadata` 文件夹。

为什么单独上传 metadata：

- metadata 与图片分层管理，后续可仅更新 metadata 版本（例如补属性）。

## 4.5 部署合约并设置 URI

部署脚本：`scripts/nft/deploy-dutch-auction.js`

执行（示例）：

```powershell
cd e:\Myhardhat\hardhat-test
$env:METADATA_CID="<your_metadata_cid>"
npx hardhat run scripts/nft/deploy-dutch-auction.js --network sepolia
```

为什么部署时同时设置 URI：

- 减少人工步骤，部署后可立即被钱包/浏览器读取。

## 4.6 铸造 NFT

铸造脚本：`scripts/nft/mint-dutch-auction.js`

执行（示例）：

```powershell
$env:DUTCH_AUCTION_ADDRESS="<deployed_address>"
$env:MINT_QUANTITY="1"
npx hardhat run scripts/nft/mint-dutch-auction.js --network sepolia
```

为什么用脚本不直接手输：

- 可重复、可审计、可复现，便于后续自动化。

## 4.7 检查链上状态

检查脚本：`scripts/nft/check-auction.js`

执行：

```powershell
$env:DUTCH_AUCTION_ADDRESS="<deployed_address>"
npx hardhat run scripts/nft/check-auction.js --network sepolia
```

关注输出：

- `totalSupply`
- `currentPrice`
- `tokenURI(0)`

为什么做这一步：

- 快速确认“合约逻辑 + 元数据路径”是否闭环。

---

## 5. 钱包不显示图片的排查经验

实际中常见问题不是图片坏了，而是 **缓存或网关兼容性**：

1. `tokenURI` 指向正常，但钱包仍显示占位图
2. Etherscan 页面未及时刷新 metadata

处理方法：

1. 将 `baseURI` 调整为 `https://ipfs.io/ipfs/<METADATA_CID>/`（提升兼容性）
2. 重新导入钱包 NFT
3. 强制刷新 Etherscan（`Ctrl+F5`）并等待缓存更新

脚本：`scripts/nft/set-custom-base-uri.js`

---

## 6. 当前项目脚本清单

- `scripts/nft/deploy-dutch-auction.js`：部署合约（可选同时设置 URI）
- `scripts/nft/set-base-uri.js`：按 `METADATA_CID` 设置 `ipfs://` BaseURI
- `scripts/nft/set-custom-base-uri.js`：按自定义 URL 设置 BaseURI
- `scripts/nft/generate-metadata.js`：生成 metadata JSON
- `scripts/nft/mint-dutch-auction.js`：执行拍卖铸造
- `scripts/nft/check-auction.js`：检查拍卖状态与 tokenURI
- `scripts/nft/set-auction-start-time.js`：设置拍卖开始时间

---

## 7. 为什么这套方案可扩展

1. 资源、元数据、合约、脚本分层清晰
2. 从 2 个 NFT 可平滑扩到大规模集合
3. 出现展示问题时可快速定位是链上、IPFS、还是钱包缓存层

这使项目不仅能“跑通”，还能“可维护、可复用、可迭代”。
