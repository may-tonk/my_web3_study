//SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract initvalue {
    bool public _bool; // false
    string public _string; // ""
    int public _int; // 0
    uint public _uint; // 0
    address public _address; // 0x0000000000000000000000000000000000000000

    enum ActionSet { Buy, Hold, Sell}
    ActionSet public _enum; // 第1个内容Buy的索引0

    function fi() internal{} // internal空白函数
    function fe() external{} // external空白函数 

    //delete炒作会初始化该类型的值；

    bool public _bool2 = true;
    function deleteBool() public returns(bool){
        delete _bool2;//此时的_bool2变成false
        return _bool2;
    }


}