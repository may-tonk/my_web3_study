// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// -------------------------------
// 空合约，用于演示合约类型参数
// -------------------------------
contract demcontract {
    // 空壳合约，不需要实现任何功能
    // 只用于在函数参数中声明“合约类型”
}

// -------------------------------
// 主合约 DemoContract
// -------------------------------
contract Democontract {
    // -------------------------------
    // 事件声明
    // -------------------------------

    // log事件，用于输出交易的 msg.data（完整 calldata）
    event log(bytes data);

    // SelectorEvent事件，用于输出函数 selector (bytes4)
    event SelectorEvent(bytes4);

    // -------------------------------
    // 函数 mint()
    // -------------------------------
    function mint() external {
        // 发出 log 事件，输出 msg.data
        // msg.data 包含函数选择器 + 参数的 ABI 编码
        emit log(msg.data);
    }

    // -------------------------------
    // mintselector() 
    // -------------------------------
    function mintselector() external pure returns (bytes4 mselector) {
        // 手动计算 mint() 的 selector
        // keccak256("mint()") → bytes32 → 取前 4 个字节 → bytes4
        return bytes4(keccak256("mint()"));
    }

    // -------------------------------
    // 状态变量 num
    // -------------------------------
    uint256 public num = 0;  
    // 用于记录函数调用次数或测试状态变量修改
    // public 会自动生成 getter

    // -------------------------------
    // 函数 elementary(uint256,uint256)
    // -------------------------------
    function elementary(uint256 p1, uint256 p2) 
        external 
        returns(bytes4 eselector, uint256 newnum) 
    {
        // 输出当前函数的 selector
        emit SelectorEvent(this.elementary.selector);

        // 手动计算 selector
        bytes4 m = bytes4(keccak256("elementary(uint256,uint256)"));

        // 修改状态变量 num
        num += 1;

        // 返回手动计算 selector 和 num
        return (m, num);
    }

    // -------------------------------
    // 函数 el(uint256[3]) - 固定长度数组
    // -------------------------------
    function el(uint256[3] memory p3) 
        external 
        returns(bytes4 elselector) 
    {
        // 输出当前函数 selector
        emit SelectorEvent(this.el.selector);

        // 手动计算 selector
        return bytes4(keccak256("el(uint256[3])"));
    }

    // -------------------------------
    // 函数 el2(uint256[]) - 动态长度数组
    // -------------------------------
    function el2(uint256[] memory p4) 
        external 
        returns(bytes4 el2selector) 
    {
        // 输出当前函数 selector
        emit SelectorEvent(this.el2.selector);

        // 手动计算 selector
        return bytes4(keccak256("el2(uint256[])"));
    }

    // -------------------------------
    // 定义结构体 user
    // -------------------------------
    struct user {
        uint256 uid;  // 用户 ID
        bytes name;   // 用户名称（动态字节数组）
    }

    // -------------------------------
    // 定义枚举 School
    // -------------------------------
    enum School {school1, school2, school3}
    // 枚举内部用 uint8 表示
    // 0 → school1, 1 → school2, 2 → school3

    // -------------------------------
    // 函数 mapselector
    // -------------------------------
    function mapselector(
        demcontract demo,            // 合约类型参数 → ABI 编码为 address
        user memory user1,           // 结构体参数 → ABI 编码为元组 (uint256,bytes)
        uint256[] memory count,      // 动态数组参数
        School myschool              // 枚举 → ABI 编码为 uint8
    ) 
        external 
        returns(bytes4 mpselector) 
    {
        // 输出函数 selector
        emit SelectorEvent(this.mapselector.selector);

        // 手动计算 selector
        // 注意：ABI signature 必须完全匹配
        // 函数名(参数类型) → (address,(uint256,bytes),uint256[],uint8)
        return bytes4(keccak256("mapselector(address,(uint256,bytes),uint256[],uint8)"));
    }

    // -------------------------------
    // 函数 callselector - 低级 call 示例
    // -------------------------------
    function callselector(
        bytes4 d1,       // 目标函数 selector
        uint256 p3,      // 参数1
        uint256 p4       // 参数2
    ) 
        external 
        returns(bool, bytes memory) 
    {
        /*
            address(this).call(...)
            -----------------------
            低级调用当前合约的函数
            abi.encodeWithSelector(d1,p3,p4) 会生成 calldata
            d1 → selector
            p3,p4 → 参数
        */

        (bool success0, bytes memory data0) = 
            address(this).call(abi.encodeWithSelector(d1, p3, p4));

        // 返回调用是否成功 + 返回数据
        return (success0, data0);
    }

}
