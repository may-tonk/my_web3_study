//SPDX-License-Identifier:MIT
pragma solidity ^0.8.24;

contract const{

    //constant和immutable  常量和不可变

    uint256 public constant num1 = 2;//constant变量必须在声明的时候初始化，之后再也不能改变。尝试改变的话，编译不通过。
    
    address immutable _ad;
    uint256 public immutable  num2;//可以声明后使用，但是赋值后就不可以改变
    //immutable 变量在 Solidity 里是 只允许赋值一次 的，并且只能在以下两种地方赋值：
    //1.声明时赋值
    //2.构造函数（constructor）中赋值

    /*function immutable_cost(uint256 _num) public returns(uint256){
       return num2 = _num;
        //在改变_num1的值是会报错；

    }错误写法，违反了2*/
    //这是一个普通的 public 函数，在部署完成后被调用的，此时合约已经创建完毕，immutable 变量已经被“锁死”，
    //所以你不能再对它赋值。

    constructor(){
        num2 = 3;
        _ad = address(this);//address(this) 表示该合约的地址
    }


}