# Merkle 白名单空投项目完整执行方案

## 1. 项目定位

### 1.1 目标
构建一个可上线的小型 Web3 空投系统，支持：

1. 基于 Merkle Tree 白名单验证资格。
2. 按批次（epoch）发放 ERC20 或 NFT。
3. 后端定时生成快照和 Merkle Root。
4. 前端一键连接钱包并完成领取。
5. 全流程可审计、可回溯、可扩展。

### 1.2 你当前阶段（非常合理）

你已经具备 Solidity + MySQL 意愿，但前端和后端还在学习中。最优策略是：

1. 先完成前端学习。
2. 再补后端核心能力（API、数据库、鉴权、定时任务）。
3. 最后按本方案分阶段落地。

这会比“边学边硬做全栈”更稳，成功率更高。

---

## 2. 项目范围（MVP 与进阶）

### 2.1 MVP 范围（第一版必须完成）

1. 合约支持 `epoch => merkleRoot`。
2. 每个叶子包含 `index + address + amount`。
3. 合约防重复领取（bitmap 或 mapping）。
4. 后端从 MySQL 生成白名单快照与 proof。
5. 管理员手动/脚本更新当期 root。
6. 前端支持用户连接钱包、查询资格、发起 claim。

### 2.2 V2 进阶（可后续追加）

1. 自动化 root 上链（定时任务 + 多签）。
2. 多活动并行（不同 token 或不同 campaign）。
3. 后台管理面板。
4. 数据看板（领取率、失败率、Gas 成本）。

---

## 3. 总体架构

```text
MySQL(用户+快照+活动)
        |
        v
Backend(API + 定时任务 + Merkle生成)
        |                 \
        |                  -> 生成 proofs / root / 记录审计
        v
Smart Contract(epoch roots + claim校验)
        ^
        |
Frontend(连接钱包/查询资格/领取)
```

### 3.1 核心原则

1. 链上只存 root，不存全量白名单地址。
2. 白名单按批次快照，不做“每来一人就更新 root”。
3. 业务判定在后端，最终约束在合约。
4. 每个 epoch 可追溯到数据库快照。

---

## 4. 技术栈建议（与你现状匹配）

### 4.1 智能合约

1. Hardhat
2. Solidity `^0.8.x`
3. OpenZeppelin (`MerkleProof`, `Ownable`, `IERC20`)

### 4.2 后端

1. Node.js + TypeScript
2. 推荐 `NestJS`（结构化强）或 `Express`（上手快）
3. MySQL
4. ORM 推荐 `Prisma`
5. 定时任务：`node-cron` 或 Nest Schedule

### 4.3 前端

1. React + Next.js
2. `wagmi` + `viem`
3. `RainbowKit`（钱包连接）

---

## 5. 数据库设计（MySQL）

### 5.1 表清单

1. `users`：用户基础信息与忠诚标签。
2. `campaigns`：空投活动配置。
3. `allowlist_epochs`：每轮快照与 root。
4. `allowlist_entries`：某一轮白名单明细。
5. `claims`：领取记录（链上事件同步或后端记录）。

### 5.2 建议字段（简化版）

```sql
CREATE TABLE users (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  wallet_address VARCHAR(42) NOT NULL UNIQUE,
  is_subscribed TINYINT(1) NOT NULL DEFAULT 0,
  loyalty_score INT NOT NULL DEFAULT 0,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE campaigns (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(100) NOT NULL,
  chain_id INT NOT NULL,
  token_address VARCHAR(42) NOT NULL,
  start_time DATETIME NOT NULL,
  end_time DATETIME NOT NULL,
  status VARCHAR(20) NOT NULL DEFAULT 'draft',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE allowlist_epochs (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  campaign_id BIGINT NOT NULL,
  epoch INT NOT NULL,
  merkle_root VARCHAR(66) NOT NULL,
  snapshot_time DATETIME NOT NULL,
  onchain_tx_hash VARCHAR(66) NULL,
  status VARCHAR(20) NOT NULL DEFAULT 'generated',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uniq_campaign_epoch (campaign_id, epoch)
);

CREATE TABLE allowlist_entries (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  epoch_id BIGINT NOT NULL,
  leaf_index INT NOT NULL,
  wallet_address VARCHAR(42) NOT NULL,
  amount VARCHAR(78) NOT NULL,
  leaf_hash VARCHAR(66) NOT NULL,
  proof_json JSON NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uniq_epoch_wallet (epoch_id, wallet_address),
  UNIQUE KEY uniq_epoch_index (epoch_id, leaf_index)
);

CREATE TABLE claims (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  campaign_id BIGINT NOT NULL,
  epoch INT NOT NULL,
  wallet_address VARCHAR(42) NOT NULL,
  amount VARCHAR(78) NOT NULL,
  tx_hash VARCHAR(66) NOT NULL,
  claimed_at DATETIME NOT NULL,
  UNIQUE KEY uniq_claim (campaign_id, epoch, wallet_address)
);
```

### 5.3 数据规范

1. `wallet_address` 入库前统一小写（或统一 checksum，二选一后全局一致）。
2. `amount` 用字符串存储，避免 JS 精度问题。
3. 对 `campaign_id + epoch`、`epoch_id + wallet_address` 建唯一索引。

---

## 6. 合约设计（MVP）

### 6.1 关键状态

1. `mapping(uint256 => bytes32) public merkleRoots;`
2. `mapping(uint256 => mapping(uint256 => uint256)) private claimedBitMap;`（推荐 bitmap）
3. `IERC20 public immutable token;`

### 6.2 关键函数

1. `setMerkleRoot(uint256 epoch, bytes32 root)`：管理员更新当轮 root。
2. `isClaimed(uint256 epoch, uint256 index)`：查询是否已领取。
3. `claim(uint256 epoch, uint256 index, address account, uint256 amount, bytes32[] calldata proof)`。

### 6.3 叶子构造（必须前后端一致）

```solidity
leaf = keccak256(abi.encodePacked(index, account, amount));
```

### 6.4 安全点

1. `require(msg.sender == account)` 防止代领（如业务不允许代领）。
2. 领取前先校验 proof，再标记 claimed，再转账（按安全顺序）。
3. 使用 `nonReentrant`（如存在外部调用风险）。
4. 管理员权限建议后续迁移到多签。

---

## 7. 后端模块拆解

### 7.1 资格判定模块

1. 输入用户行为数据（订阅、积分、交互）。
2. 输出是否入选和可领取数量。

### 7.2 快照任务模块（定时）

1. 按 campaign 拉取符合资格的地址。
2. 生成 `[{index, address, amount}]`。
3. 生成 Merkle Tree、root、proof。
4. 写入 `allowlist_epochs` 与 `allowlist_entries`。

### 7.3 上链更新模块

1. 读取最新 epoch 的 root。
2. 调用合约 `setMerkleRoot(epoch, root)`。
3. 回写交易哈希和状态。

### 7.4 API 模块

1. `GET /campaigns/:id/current-epoch`
2. `GET /campaigns/:id/proof?address=0x...`
3. `GET /campaigns/:id/eligibility?address=0x...`
4. `POST /admin/campaigns/:id/generate-epoch`
5. `POST /admin/campaigns/:id/push-root`

---

## 8. 前端模块拆解

### 8.1 用户页面

1. 连接钱包。
2. 显示是否有资格。
3. 显示可领数量。
4. 点击领取并显示交易状态。

### 8.2 管理页面（可晚做）

1. 触发快照。
2. 查看 epoch/root 状态。
3. 查看领取统计。

### 8.3 前端注意点

1. 永远不要只信前端资格判断。
2. 前端仅展示后端结果 + 发起链上交易。
3. 对常见错误做中文提示（proof 失效、已领取、余额不足、网络错误）。

---

## 9. 里程碑计划（建议 6 周）

### 第 1 周：学习收尾与基础搭建

1. 前端：完成钱包连接、网络切换、合约读写基础。
2. 后端：完成 Node + MySQL + Prisma 基础 CRUD。
3. 输出：本地跑通“地址入库 + 查询”。

### 第 2 周：合约实现与单测

1. 完成 `MerkleAirdrop` 合约。
2. 完成核心测试：正确 proof、错误 proof、重复领取。
3. 输出：测试通过率 100%。

### 第 3 周：后端快照与 proof 生成

1. 完成快照任务。
2. 完成 root/proof 入库。
3. 输出：可从某地址查到正确 proof。

### 第 4 周：前端领取流程

1. 完成资格查询页面。
2. 完成 claim 交易流程。
3. 输出：测试网完整闭环领取成功。

### 第 5 周：联调与异常处理

1. 处理各种失败场景。
2. 增加日志与告警。
3. 输出：稳定性验收通过。

### 第 6 周：预上线与文档

1. 部署测试环境。
2. 回归测试。
3. 编写运维文档与应急预案。

---

## 10. 测试策略

### 10.1 合约测试（必须）

1. 正确 proof 可以领取。
2. 非白名单地址领取失败。
3. 同一 index 二次领取失败。
4. 错误 epoch 领取失败。
5. root 更新后旧 proof 行为符合预期（按你的业务规则）。

### 10.2 后端测试

1. 快照生成结果可复现。
2. proof 与合约验证一致。
3. 边界值：空名单、重复地址、大名单。

### 10.3 前端测试

1. 钱包未连接提示。
2. 网络不匹配提示。
3. 交易 pending/success/fail 状态显示正确。

---

## 11. 风险清单与规避

### 11.1 高风险

1. 前后端叶子哈希不一致 -> 统一工具函数并写测试。
2. 地址格式混乱 -> 入库前强制标准化。
3. 高频更新 root -> 固定批次（每日/每周）。

### 11.2 运维风险

1. 管理员私钥泄露 -> 使用多签或硬件/KMS。
2. 空投池余额不足 -> 上链前余额检查。
3. 链拥堵 -> 前端提供重试和 Gas 提示。

---

## 12. 上线前 Checklist

1. 合约已审查关键逻辑（proof、防重领、权限）。
2. 测试网完成至少 3 轮 epoch 演练。
3. root 生成脚本支持回放验证。
4. 数据库已开启备份。
5. 管理员操作有日志与审批。
6. 前端错误提示完整。
7. 发布后有监控（失败率、领取率、异常交易）。

---

## 13. 你学习完成后的执行顺序（直接照做）

1. 先实现并测通合约。
2. 再建 MySQL 表 + Prisma。
3. 实现快照脚本和 proof API。
4. 实现前端领取页。
5. 本地联调成功后上 Sepolia。
6. Sepolia 跑 2~3 个 epoch 后再考虑主网。

---

## 14. 验收标准（Definition of Done）

满足以下全部条件即项目完成：

1. 用户可在前端连接钱包并成功领取。
2. 非白名单用户无法领取且提示明确。
3. 同一地址不可重复领取。
4. 可生成并上链新的 epoch root。
5. 任意一笔领取都可在数据库追溯到快照记录。
6. 关键异常有日志并可定位。

---

## 15. 后续可扩展方向

1. 支持 NFT 空投（ERC721/1155）。
2. 支持多链空投（按 chainId 分活动）。
3. 引入 EIP-712 签名方案，减少频繁 root 更新需求。
4. 增加运营后台图表与导出。

---

## 16. 给未来执行时的备注

1. 先做 MVP，不追求一步到位。
2. 任何“动态实时加白”需求，先评估是否可以改成“分钟级批次”。
3. 如果业务经常变化，优先保证“快照可复现”和“操作可回溯”。

这个方案已经按你当前学习路径设计好。等你学完后端，我们就可以按第 13 节直接开工。
