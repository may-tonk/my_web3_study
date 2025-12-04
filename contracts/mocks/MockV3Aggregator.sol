// SPDX-License-Identifier: MIT
// SPDX 许可证标识符，表明该合约使用 MIT 开源许可。
// 这是 Solidity 0.6.8+ 的要求，方便工具识别许可类型。
pragma solidity ^0.8.24; 
// 指定 Solidity 编译器版本为 0.8.24 或以上，确保语法和特性一致。

// 导入 Chainlink 的 Aggregator 接口，用于价格聚合器的标准接口。
// 我们将实现这个接口来模拟 Chainlink 价格源。
import "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

// 定义一个合约 MockV3Aggregator，实现 AggregatorV3Interface 接口。
// 这个合约用于本地或测试环境模拟 Chainlink 价格源。
contract MockV3Aggregator is AggregatorV3Interface {

    // 定义小数位数，和 Chainlink 的 decimals 保持一致。
    uint8 public decimals;

    // 存储最新的价格/答案
    int256 public latestAnswer;

    // 存储最新的轮次编号
    uint80 public latestRound;

    // 合约版本号，可用于标识 Mock 版本
    uint256 public version = 1;

    // 构造函数，初始化合约
    // _decimals: 小数位
    // _initialAnswer: 初始价格
    constructor(uint8 _decimals, int256 _initialAnswer) {
        decimals = _decimals;           // 设置小数位
        latestAnswer = _initialAnswer;  // 设置初始价格
        latestRound = 1;                // 初始化轮次为 1
    }

    // getRoundData 函数，用于获取指定轮次的价格数据
    // Chainlink 接口要求返回五个值：
    // roundId - 当前轮次编号
    // answer - 价格值
    // startedAt - 数据开始时间
    // updatedAt - 数据更新时间
    // answeredInRound - 数据所在轮次
    function getRoundData(uint80 _roundId)
        external
        view
        override  // 实现接口的函数必须加 override
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        )
    {
        // 模拟返回数据
        // 使用 block.timestamp 代替实际 Chainlink 时间戳
        return (_roundId, latestAnswer, block.timestamp, block.timestamp, _roundId);
    }

    // latestRoundData 函数，返回最新一轮的价格数据
    function latestRoundData()
        external
        view
        override
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        )
    {
        // 返回最新轮次的数据
        return (latestRound, latestAnswer, block.timestamp, block.timestamp, latestRound);
    }

    // description 函数，返回合约描述信息
    function description() external pure override returns (string memory) {
        return "MockV3Aggregator";
    }
}







