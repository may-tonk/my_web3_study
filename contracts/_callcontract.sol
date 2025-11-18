//SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract othercontract{

    uint256 private _x;
    event log(uint256 amount,uint256 gas);

    function receiveETH(uint256 x) public payable{
        _x = x;
        if(msg.value>0){
            emit log(msg.value,gasleft());
        }
    }

    function getbalance() public view returns(uint256){
        return address(this).balance;

    }

    function getx() public view returns(uint256 x){

        return x=_x;
    }


}




contract callcontract{

    function sendETH(othercontract _address,uint256 x) public payable{//_address 是othercontract合约的地址 x 是接受的ETH数量
    othercontract(_address).receiveETH(x);//只是调用receive中的x进行改变

    }

    function getothercontract_x1(othercontract _address) external view returns(uint256 x){//使用othercontract调用_address
    //声明othercontract 
        x = _address.getx();


    }
      
    function getothercontract_x2(address _address) external view returns(uint256 x){
        //声明address 以othercontract调用_address
        othercontract oc = othercontract(_address);
        x = oc.getx();

    }

    function otherreceiveETH(address _address,uint256 amount) public payable{
        othercontract(_address).receiveETH{value:msg.value}(amount);//对于receive中的emit进行操作

    /*{value: ...}: 这是一个特殊语法，用于在调用另一个合约的函数时，指定本次子调用要附带的 ETH 数量。

msg.value: 在这个上下文中，msg.value 是调用者发送给 当前合约 (otherreceiveETH 所在的合约) 的 ETH 数量。

结果： 这一步将当前合约收到的所有 ETH (msg.value)，全部转发给了 othercontract 上的 receiveETH 函数。*/


    }

}