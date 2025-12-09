// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract WhitelistNFT is ERC721,Ownable{          // 注意这里有空格！

    bytes32 public merkleRoot;                     // 变量名更清晰

    uint256 public nextTokenId = 1;  
    
    address public account;               // 从 1 开始，符合 NFT 习惯

    // 记录这个地址是否已经铸造过
    mapping(address => bool) public hasMinted;     // 名字清晰多了

    constructor(bytes32 _merkleRoot,address account1) ERC721("Ran_Ji", "SB") Ownable(msg.sender){
        merkleRoot = _merkleRoot;
        account = account1;
    }

    // 白名单铸造函数
    function whitelistMint(bytes32[] calldata proof) external {
        // 1. 没铸过
        require(!hasMinted[account], "Already minted");//为了方便测试所以改为手动输入地址，一般是msg.sender


        // 2. 构造当前地址的 leaf 节点（和生成 root 时保持一致！）
        bytes32 leaf = keccak256(abi.encodePacked(account));

        // 3. 验证 proof 是否正确
        //    注意参数顺序：proof, root, leaf   ← 很多人写反！
        require(
            MerkleProof.verify(proof, merkleRoot, leaf),
            "Invalid Merkle Proof"
        );

        // 4. 标记为已铸造
        hasMinted[account] = true;

        // 5. 铸造 NFT（tokenId 从 1 开始递增）
        _safeMint(account, nextTokenId);   // 推荐用 _safeMint，更安全
        nextTokenId++;
    }

    // 可选：owner 随时更新 root（比如分阶段白名单）
    function setMerkleRoot(bytes32 _newRoot) external onlyOwner {
        merkleRoot = _newRoot;
    }
}