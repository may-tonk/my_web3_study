//SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./_library1.sol";

contract _library{

    using Strings for string;//需要使用的类型，不需要显示传递，注意当改变library时也需要改变相应的使用类型

    function getstrings(string memory  ad) public pure returns(string memory){
        return ad.adds();//调用library函数,无论传什么字符都显示520

    }

}