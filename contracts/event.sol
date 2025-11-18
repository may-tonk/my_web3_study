//SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;


contract eventTest{
    event Transfer(address indexed from,uint256 amount,address indexed to);//这是跟踪交易
    

    mapping (address => uint) public _balance;//对应地址的资金

    function trans(address from,uint256 amount,address to) public {

        _balance[from]+=1000000;//交易的大概流程
        _balance[from]-=amount;
        _balance[to]+=amount;

        //释放信息
        emit Transfer(from,amount,to);


    }
}