//SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;


contract mod{
    address public owner;
    constructor(){
        owner = msg.sender;
    }
    address public _ad;
    function only() public owneronly view returns(uint){
        return 1;
    }
    modifier owneronly{//这里的_;在后表示先检查条件是否正确在去执行函数，_;在前表示先执行再检查
        require( owner == _ad,"sb,tis is an error" );
        _;
    }


}