const { MerkleTree } = require('merkletreejs')
const keccak256 = require('keccak256')

// 示例白名单地址
const whitelist = [
  "0x1111111111111111111111111111111111111111",
  "0x2222222222222222222222222222222222222222",
  "0x3333333333333333333333333333333333333333"
]

// 将地址转换为叶子节点（Leaf）
const leaves = whitelist.map(addr => keccak256(addr))

// 创建 Merkle Tree
const tree = new MerkleTree(leaves, keccak256, { sortPairs: true })

// 获取 Merkle Root
const root = tree.getHexRoot()
console.log("Merkle Root:", root)


const leaf = keccak256("0x2222222222222222222222222222222222222222")

// 获取 proof 用于智能合约验证
const proof = tree.getHexProof(leaf)

console.log("Merkle Proof:", proof)


// 验证某地址是否在白名单中
const isValid = tree.verify(proof, leaf, root)

console.log("验证结果:", isValid)


