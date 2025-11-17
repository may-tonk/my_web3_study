//SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import "./event.sol";

contract Error is eventTest{
    error addresserror();//addresserror()中还可以传参数

    address public owner;

    constructor(){//constructor需要加()

        owner = msg.sender;
    }
    
    uint256 public amount;
    address public to;

    event transfer(address from,uint256 amount,address to);


    function tran(address _ad) public view {
        if(_ad!=owner){
            revert addresserror();//revert 需要配合error使用，gas费最少
        }

    }

    function amount_(uint256 _am) public view {
        require(_am == amount,"_am is error,_am imrequire amount");//判断是否是true,否着显示错误，gas费最多
        
    }

    function assert_(address To) public view{
        assert(To==to);
        //该错误不会掏出error只是进行判断

    }


}