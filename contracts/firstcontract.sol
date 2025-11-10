//SPDX-License-Identifier:MIT
pragma solidity ^0.8.24;


contract firstfund{
    mapping(address=>uint256) public liststorage;//映射

    struct person{
        address addres;
        uint256 amount;
    }

    person[] public sender;


    function fund1(address addr,uint256 num2) public {
        sender.push(person(addr,num2));
        liststorage[addr] = num2;

    }

    function retireve(address _ad) public view returns(uint256){
        return liststorage[_ad];
        } 

    

}