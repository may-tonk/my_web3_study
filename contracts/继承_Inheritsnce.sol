//SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract god{
    event log(string message);
    //先来一个parent
    function foo() public virtual{//函数涉及到相同时要是用virtual，在son合约中也要使用override。但是在某些情况下，
    //比如虽然函数名相同但是串的参数不同，是不需要是用virtual 和override的。
        emit log("sb");
    }

    function bar() public virtual{
        emit log("nb");
    }


}

//再来一个son

contract son is god{
    function foo() public override{
        emit log("son is sb");

        super.foo();//这个表示调用最近的父合约;
    }

}


//modifier也是可以继承的同样需要virtual 和 override

/*多合约继承需要按最大的合约降序排序比如 grandson is god,bab,son
这时候使用super时是调用当前合约最近的然后再向上调用;
*/

//还有多合约中有相同函数时需要使用override(A父合约,B父合约)










