// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract Pair {

    // 工厂合约地址（只允许工厂初始化交易对）
    address public factory;
    // 交易对的两个代币
    address public token0;
    address public token1;

    constructor() {
        // 工厂合约会通过 `new Pair()` 调用这个构造函数
        // msg.sender 就是 PairFactory
        factory = msg.sender;
    }

    // 由工厂在部署后调用，用来设置 token0 和 token1
    function initialize(address _token0, address _token1) external {
        // 安全检查：只有工厂可以初始化
        require(msg.sender == factory, "error please check msg.sender or factory");

        token0 = _token0;
        token1 = _token1;
    }
}


contract Pairfactory {

    // 通过 (tokenA → tokenB) 查询对应的交易对 Pair 合约地址
    mapping(address => mapping(address => address)) public getPair;

    // 所有已创建的 Pair 合约地址列表
    address[] public allPair;

    function createPair(address tokenA, address tokenB)
        external
        returns (address pairaddr)
    {
        // 部署新的交易对合约 Pair
        Pair pair = new Pair();

        // 初始化交易对的 token0 和 token1（必须由工厂调用）
        pair.initialize(tokenA, tokenB);

        // 记录交易对合约地址
        pairaddr = address(pair);
        allPair.push(pairaddr);

        // 建立 tokenA <-> tokenB 的映射，便于查询交易对
        getPair[tokenA][tokenB] = pairaddr;
        getPair[tokenB][tokenA] = pairaddr;
    }
}
