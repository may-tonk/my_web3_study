//SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract insret{

    uint public num = 1;

    function ifElseTest() public view returns(uint) {//if-else语法上和c是一样的
        if(num == 1){
            return num;

        }
        else{
            return 0;
        }
    }


    function forlooptest() public view returns(uint){
        uint num1 = 0;
        for(uint i = 0;i<4;i++){
            num1+=i;

        }
        return num;
    }


    function whileSool() public view returns(uint){
        uint num2 = 0;
        while(num!=7){
            num2++;
        }
        return num2;

    }


    //三元运算
    function teraryTest(uint _x,uint _y) public pure returns(uint){
        return _x >= _y ? _x : _y;

    }

    //插序
    //这个地方有个电脑注意点是使用uint类型是要注意uint是无符号整数型，代码当中要防止出现负数的可能

    function insertionSort(uint[] memory a) public pure returns(uint[] memory){
        for(uint i = 1;i <a.length; i++){
            uint temp = a[i];
            uint j = i;
            while((j>=1)&&(temp <a[i-1])){
                a[j] = a[j-1];
                j--; 
            }
            a[j] = temp;
        }

        return a;
    }

}