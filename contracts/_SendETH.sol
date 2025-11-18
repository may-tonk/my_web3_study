// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract SendETH{
    constructor() payable{

    }

    error sendETHfail();

    error callETHfail();

    function transferETH(address _to,uint256 amount) public payable{
        payable(_to).transfer(amount);//transfer转ETH 2300gas限制

    }

    function sendETH(address _to,uint256 amount) public payable{
        bool success = payable(_to).send(amount);//send转ETH，有一个返回值bool类型 2300gas限制
        if(!success){
            revert sendETHfail();

        }
    }

    function callETH(address _to,uint256 amount) public payable{
        (bool success,) = payable(_to).call{value:amount}("");//call转ETH，有两个返回值一个是bool类型，一个是msg.data 无gas限制
        if(!success){
            revert callETHfail();

        }
    }

}



contract Receive{
    event log(uint256 amount,uint256 gas);

    receive() external payable{
        emit log(msg.value,gasleft());

    }
    function getbalance() public view returns(uint256) {
        return address(this).balance;

    }
}



