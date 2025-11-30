// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// ------------------ caluacationcontract ------------------
// 用于演示 try-catch 的合约
contract caluacationcontract {

    // 构造函数
    constructor(uint256 a1){
        // a1 不能为 0，否则 revert 并返回错误信息
        require(a1 != 0, "hhha you are sb");

        // a1 不能为 1，否则 panic
        assert(a1 != 1);
    }

    // 公共函数，检查输入是否为偶数
    function calucation(uint256 a) public pure returns(bool success){
        // 输入必须为偶数，否则 revert 并返回错误信息
        require(a % 2 == 0, "fuke ,look carfully");
        success = true; // 返回 true 表示成功
    }
}

// ------------------ trycatch ------------------
// 演示 try-catch 的使用
contract trycatch {

    // ------------------ 事件定义 ------------------
    event logstring(string message); // 捕获 revert 的字符串信息
    event logbytes(bytes data);      // 捕获低级错误信息
    event logsuccess();              // 成功事件

    event loguint256(uint256 dd);

    // ------------------ 状态变量 ------------------
    caluacationcontract _even; // 保存 caluacationcontract 实例
    uint256 public num1;        // 测试用数字

    // ------------------ 构造函数 ------------------
    constructor(){
        // 部署 caluacationcontract 实例，传入 3
        // 3 != 0 ✅ 3 != 1 ✅ 合法
        _even = new caluacationcontract(3);
    }

    // ------------------ try-catch 调用已存在合约函数 ------------------
    function excutiontrycatch(uint256 num) external returns(bool success1){
        try _even.calucation(num) returns (bool _success) {
            // 调用成功，触发事件
            emit logsuccess();
            return _success;
        } catch Error(string memory reason){
            // 捕获 require/revert 错误，触发事件
            emit logstring(reason);
            return false;
        } catch (bytes memory reason){
            // 捕获低级错误，触发事件
            emit logbytes(reason);
            return false;
        } 
    }

    // ------------------ try-catch 动态创建合约 ------------------
    function excution2(uint256 num) external returns(bool success){
        try new caluacationcontract(num) returns (caluacationcontract even) {
            // 创建合约成功，触发事件
            emit logsuccess();
            // 调用新合约函数，使用传入的 num
            success = even.calucation(num);
        } catch Error(string memory reason){
            // 捕获构造函数或函数 revert 错误
            emit logstring(reason);
            return false;
        } catch (bytes memory reason){
            // 捕获低级错误
            emit logbytes(reason);
            return false;
        }catch Panic(uint256 reason){
            //捕捉assert(a1!=1)的错误
            emit loguint256(reason);
            return false;

        }
    }
}





