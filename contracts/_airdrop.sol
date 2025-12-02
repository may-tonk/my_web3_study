// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// ❌ 注意：你这里 import "./_ERC20.sol" 如果只是为了 IERC20，不需要继承 ERC20。
// 空投合约不需要继承 ERC20，只需引用 IERC20 即可。

contract airdrop {
    // 引用已有的 ERC20 代币接口
    IERC20 immutable token;

    // 记录每个地址空投到的代币数量，可选
    mapping(address => uint256) _p;

    // 构造函数，初始化 ERC20 代币地址
    constructor(address _token) {
        require(_token != address(0), "Token address cannot be zero");
        token = IERC20(_token);
    }

    // 计算 uint256 数组总和
    // pure 修饰符，因为不访问状态变量
    function getSum(uint256[] calldata d) public pure returns (uint256) {
        uint256 Sum;
        for (uint256 i = 0; i < d.length; i++) { // 循环遍历数组
            Sum += d[i];
        }
        return Sum;
    }

    // 批量空投 ERC20 代币
    function transfertoken(
        address[] calldata add,       // 用户地址数组
        uint256[] calldata amount     // 对应每个用户的空投数量
    ) public {
        require(add.length == amount.length, "transfer error"); // 数组长度必须一致

        uint256 _amount = getSum(amount); // 计算总空投数量

        // 检查 msg.sender 是否 approve 给合约足够代币
        require(token.allowance(msg.sender, address(this)) >= _amount, "Allowance not enough");

        // 循环批量转账
        for (uint256 i = 0; i < add.length; i++) {
            token.transferFrom(msg.sender, add[i], amount[i]); // 调用 ERC20 transferFrom
            _p[add[i]] += amount[i]; // 可选：记录每个地址收到的代币数量
        }
    }

    // 批量发送 ETH
    function sendeth(address[] calldata add, uint256[] calldata amount) public payable {
        require(add.length == amount.length, "transfer error");

        uint256 _amount = getSum(amount); // 计算总发送数量

        // 检查发送者 msg.value 是否足够支付总金额
        require(msg.value >= _amount, "balance not enough");

        // 循环发送 ETH
        for (uint256 i = 0; i < add.length; i++) {
            // 使用低级 call 发送 ETH，防止失败导致整个交易回滚
            (bool success,) = add[i].call{value: amount[i]}(""); 
            require(success, "ETH transfer failed"); // ✅ 强烈建议检查返回值
        }
    }
}
