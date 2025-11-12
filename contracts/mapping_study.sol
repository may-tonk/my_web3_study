//SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract mapp{
    //如果映射声明为public，那么Solidity会自动给你创建一个getter函数，可以通过Key来查询对应的Value
    mapping(address=>uint256) public Identification;//mapping只可以用Solidity内置的值类型比如uint，address等，不能用自定义的结构体


    //以下是简单的mapping应用
    function mappi(address _ad,uint256 _value) public {
        Identification[_ad] = _value;

    }


    function Receive(address _ad) public view returns(uint256) {//该功能和在mapping时声明public是一样的用于查看address对应的value
        return Identification[_ad];

    }

    //因为Ethereum会定义所有未使用的空间为0，所以未赋值（Value）的键（Key）初始值都是各个type的默认值，如uint的默认值是0
    
}

