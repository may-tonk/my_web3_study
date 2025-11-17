//SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

//函数名相同但是传的参数不同时不会包错的，不需要重写，也就是virtual 和 override
import "./jicheng_Inheritsnce.sol";

contract overload is god{

    string public constant str="520";//状态常量可以使用pure，因为他没有上链storage

    function foo(string memory s) public pure returns(string memory){
        s=str;
        return s;

    }

}