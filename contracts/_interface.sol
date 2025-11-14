//SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;


//这节是关于抽象合约和接口合约的理解实验
abstract contract Base{
    string public name = "Base";
    function getAlias() public pure virtual returns(string memory);
}

contract BaseImpl is Base{
    function getAlias() public pure override returns(string memory){
        return "BaseImpl";
    }
}

    //该函数没有{}另外，未实现的函数需要加virtual，以便子合约重写
        
    



/*接口类似于抽象合约，但它不实现任何功能。接口的规则：

不能包含状态变量
不能包含构造函数
不能继承除接口外的其他合约
所有函数都必须是external且不能有函数体
继承接口的非抽象合约必须实现接口定义的所有功能
*/

//接口只可以使用external 外部查看


/*

interface Base {
    function getFirstName() external pure returns(string memory);
    function getLastName() external pure returns(string memory);
}
contract BaseImpl is Base{
    function getFirstName() external pure override returns(string memory){
        return "Amazing";
    }
    function getLastName() external pure override returns(string memory){
        return  "Ang";
    }
}

*/