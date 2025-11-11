//SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract arrayandstruct{
    bytes public array1;//bytes是数组但是不用加[]
    uint[3] public array2;//固定数组长
    address[4] public array3;

    //这种采用是静态数组方式


    //接下来是采用动态方式实现
    //使用函数直接定量填充
    function initArray() external pure returns(uint[] memory){
        uint[] memory x = new uint[](3);
        x[0] = 1;
        x[1] = 3;
        x[2] = 4;
        return(x);
    }  

    function g() external pure returns (uint256[2] memory) {
    uint256[2] memory x = [uint256(1), 2];
    return x;
    }


    uint[] public array4; // 动态数组这里你创建的是 固定长度数组 uint256[2]，
//但函数返回的是 uint256[] memory（动态数组），类型不匹配 

//固定数组不能直接返回为动态数组。

    function h() external returns (uint[] memory) {
    array4.push(1);//固定长度数组（uint[3]），不能使用 .push()
    array4.push(2);
    return array4;
    }


    //定义结构体，通常定义合约结构体来管理钱包地址对应的资金

    struct Owner{
        address ad;
        uint256 value;
    }//地址和资金
    
    Owner only;
    function f() external pure returns (Owner memory) {
    Owner memory temp = Owner({
        ad: 0x0000000000000000000000000000000000000001,
        value: 2
    });
    return temp;
    }

    function initOwner() external {
    only = Owner(0x0000000000000000000000000000000000000002, 90);
    }

}