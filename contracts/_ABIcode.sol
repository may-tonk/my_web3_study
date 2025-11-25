// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/*
  合约名：ABIencode
  目的：演示和比较 Solidity 中几种 ABI 编码方式：
    - abi.encode
    - abi.encodePacked
    - abi.encodeWithSignature
    - abi.encodeWithSelector
  并包含一个能把 abi.encode 生成的数据解码回原始值的 decode 函数。
*/
contract ABIencode {

    // --- 状态变量（存储在链上 storage） ---
    // 注意：这些变量是示例用的初始值，实际部署时这些值也会存储在合约的 storage 中。
    uint x = 10; // uint 等同于 uint256，存储一个无符号整数
    address addr = 0x7A58c0Be72BE218B41C608b7Fe7C5bB630736C71; // 示例地址
    string name = "0xAA"; // 动态类型 string
    uint[2] array = [5, 6]; // 固定长度数组，包含两个 uint

    // -------------------------
    // 1) abi.encode —— 完整的 ABI 编码（带长度信息、按 ABI 规范对齐）
    // -------------------------
    // view：函数不会修改区块链状态（只读），因此可以标记为 view。
    // 返回 bytes memory，包含按 ABI 编码后的一段字节（这是标准可解码的格式）。
    function encode() public view returns (bytes memory data) {
        // abi.encode 会把所有参数按 ABI 规范编码，动态类型（string）会包含长度/偏移信息。
        // 该返回值可以被 abi.decode 直接反向解析（只要用相同的类型序列）。
        data = abi.encode(x, addr, name, array);
    }

    // -------------------------
    // 2) abi.encodePacked —— 紧凑编码（不保留长度信息，对动态类型紧凑拼接）
    // -------------------------
    // 注意：encodePacked 常用于生成短的唯一标识（如组合哈希），但**不适合后续通过 abi.decode 恢复**
    function encodePacked() public view returns (bytes memory data) {
        // abi.encodePacked 将参数紧密拼接，不按 32 字节对齐，也不为每个动态类型记录长度/偏移。
        // 结果更短，但可能导致不同参数组合产生相同的字节串（碰撞），因此用于哈希前缀时需小心。
        data = abi.encodePacked(x, addr, name, array);
    }

    // -------------------------
    // 3) abi.encodeWithSignature —— 在编码前添加 function selector（用字符串描述签名）
    // -------------------------
    // 传入一个函数签名字符串（例如 "foo(uint,address,string,uint[2])"）
    // abi.encodeWithSignature 会把 selector (前 4 字节) + 参数 ABI 编码 拼接返回。
    // 注意：这里使用 "uint" 等同于 "uint256"，"uint[2]" 等同于 "uint256[2]"。
    function encodeWithSignature() public view returns (bytes memory data) {
        // 该函数**只返回准备好的 calldata**（包含 selector），并不会调用任何函数。
        // 如果你想实际发起调用，需要把返回的 bytes 用 low-level call 发出去，例如:
        // (bool ok, bytes memory ret) = someAddress.call(data);
        data = abi.encodeWithSignature("foo(uint,address,string,uint[2])", x, addr, name, array);
    }

    // -------------------------
    // 4) abi.encodeWithSelector —— 手动提供 selector，再编码参数
    // -------------------------
    // 更安全的方式是使用已知的 selector（例如通过 keccak256 计算），而不是靠字符串。
    // bytes4(keccak256("foo(uint,address,string,uint[2])")) 与 abi.encodeWithSignature 的 selector 一致。
    function encodeWithSelector() public view returns (bytes memory data) {
        // bytes4(keccak256("...")) 计算函数选择器（前 4 字节）。
        // encodeWithSelector 会把该 selector 拼在参数编码前面返回。
        data = abi.encodeWithSelector(
            bytes4(keccak256("foo(uint,address,string,uint[2])")),
            x,
            addr,
            name,
            array
        );
    }

    // -------------------------
    // 5) decode —— 演示如何用 abi.decode 解码数据
    // -------------------------
    // 注意：abi.decode 需要传入正确的类型序列。此函数采用 pure（不读写 storage）；
    // 它假定传入的 data 符合 (uint,address,string,uint[2]) 的编码规范（即必须是 abi.encode 的结果，不包含 selector）。
    function decode(bytes memory data)
        public
        pure
        returns (uint _x, address _addr, string memory _name, uint[2] memory _array)
    {
        // 只要 data 是通过 abi.encode(x, addr, name, array) 生成的，
        // 下面的 abi.decode 就会把它恢复回原始四个值。
        (_x, _addr, _name, _array) = abi.decode(data, (uint, address, string, uint[2]));
    }
}
