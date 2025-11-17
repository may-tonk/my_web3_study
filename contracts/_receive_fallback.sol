// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract Receive{

    address public owner;
    event transfer(address from,uint256 amount ,address to);


    receive() external payable{//直接向该合约地址充值，没有信息时msg.data
        emit transfer(msg.sender,msg.value,owner);//emit 的参数要和event的参数数量相同
    }

    fallback() external payable{//在receive不存和有msg.data时使用

        emit transfer(msg.sender,msg.value,owner);//emit 的参数要和event的参数数量相同
    }

}