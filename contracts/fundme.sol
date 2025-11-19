// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// 从 Chainlink 导入价格数据接口
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

// 定义一个名为 fundyou 的库（library）
// 库里面封装了一些与价格转换相关的函数
contract fundme{
    uint256 public minnal = 1e18;
    address[] public funders;

    constructor(){};

    function fund() public payable{
        require(getconversion(msg.value)>=minnal,"send last 1 ETH");
        funders.push(msg.sender);

    }
    // 获取 ETH / USD 价格
    function getprice() public view returns (uint256) {
        // Chainlink ETH/USD 预言机地址（Sepolia 测试网）
        AggregatorV3Interface pricefeed = AggregatorV3Interface(
            0x694AA1769357215DE4FAC081bf1f309aDC325306
        );

        // 获取最新一轮价格数据
        // latestRoundData() 返回五个值，我们只需要第二个 price
        (, int256 price, , , ) = pricefeed.latestRoundData();

        // Chainlink 返回的 ETH/USD 价格精度是 8 位小数（即 1e8）
        // 这里乘上 1e10，把它转换成 1e18 的形式（和以太币精度保持一致）
        return uint256(price * 1e10);
    }

    // 把 ETH 数量转换成等值的 USD
    function getconversion(uint256 ethAmount) public view returns (uint256) {
        uint256 ethprice = getprice(); // 获取当前 1 ETH 的美元价格
        // 计算：ETH 数量 × ETH 价格 / 1e18（因为 ETH 的单位是 Wei）
        uint256 ethusd = (ethprice * ethAmount) / 1e18;
        return ethusd; // 返回等值的 USD 金额
    }

    // 获取 Chainlink Aggregator 的版本号
    function getversion() public view returns (uint256) {
        AggregatorV3Interface pricefeed = AggregatorV3Interface(
            0x694AA1769357215DE4FAC081bf1f309aDC325306
        );
        return pricefeed.version();
    }
    receive() external payable {
        fund();
     }
     fallback() external payable{
        fund();
     }
}