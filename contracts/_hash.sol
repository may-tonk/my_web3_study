// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/*
  合约名：Hash
  功能：
  1. 演示 keccak256 哈希函数的使用
  2. 通过 abi.encodePacked 生成哈希
  3. 验证输入字符串是否与存储的哈希一致
  4. 比较两个输入字符串哈希是否一致
*/
contract Hash {

    // -------------------------
    // 1) 初始化存储哈希
    // -------------------------
    // abi.encodePacked("0xAA") 将字符串 "0xAA" 转换为紧凑字节流
    // keccak256(...) 返回 32 字节哈希
    // _msg 存储了 "0xAA" 的哈希，用于后续验证
    bytes32 public _msg = keccak256(abi.encodePacked("0xAA"));

    // -------------------------
    // 2) 示例状态变量
    // -------------------------
    uint public x = 10; // uint256 类型的整数
    string public name = "0xff"; // 字符串
    address public add = 0x7A58c0Be72BE218B41C608b7Fe7C5bB630736C71; // 示例地址

    // -------------------------
    // 3) hash() 函数
    // -------------------------
    // 作用：返回 x、name、add 拼接后的哈希
    // view：因为只读取了 storage（x, name, add），没有修改状态
    function hash() public view returns(bytes32) {
        // abi.encodePacked 将多个参数紧凑拼接为字节流
        // keccak256 对拼接后的字节流计算哈希
        return keccak256(abi.encodePacked(x, name, add));
    }

    // -------------------------
    // 4) justice() 函数
    // -------------------------
    // 作用：检查输入字符串 st 的哈希是否等于 _msg
    // view：因为读取了 storage 变量 _msg
    function justice(string memory st) public view returns(bool) {
        // 将输入字符串 st 编码为紧凑字节流
        // 然后计算哈希与 _msg 对比
        return keccak256(abi.encodePacked(st)) == _msg;
    }

    // -------------------------
    // 5) justic2() 函数
    // -------------------------
    // 作用：比较两个输入字符串 st1 和 st2 的哈希是否相同
    // pure：不读取或修改任何 storage
    function justic2(string memory st1, string memory st2) public pure returns(bool) {
        return keccak256(abi.encodePacked(st1)) == keccak256(abi.encodePacked(st2));
    }

}
