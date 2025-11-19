//SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;


contract othercontract{

    uint256 private _x;
    event log(uint256 amount,uint256 gas);

    fallback() external payable{}//给任何没有msg.data兜底，无敌的存在
    receive() external payable{}//大多数请款下fallback() 需要和receive()一起是用，不然可能有警告


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


contract callETH{

    event repend(bool success,bytes  data);
    //测试call的abi        abi.encodeWithSignature("函数签名", 逗号分隔的具体参数)
    //注意使用call是有返回值的 bool 和uint256
    //目标合约地址.call(字节码);这个地址为payable(addresss)
    
    function callreceiveETH(address _address,uint256 x) public payable{

        (bool success,bytes memory data) = payable(_address).call{value:msg.value}(

            abi.encodeWithSignature("receiveETH(uint256)",x));//需要调用合约的函数名和传参
            //此时的x为input    而byte memory data是返回值的ABI编码
            //ABI编码是一个16进制


        emit repend(success,data);/*emit repend(success, data) 中的 data 不是 x 的 ABI 编码，而是：

目标合约 receiveETH(uint256) 的返回值（return data）的 ABI 编码。*/
    }


    function callgetx(address _address)  public  returns(uint256){//call 不是 view 函数

//你把 callgetx 声明为 view，但是 call 是外部调用，会修改状态或者是低级调用，不能加 view，否则报错。

        (bool success,bytes memory data)  = _address.call(abi.encodeWithSignature("getx()"));

        emit repend(success,data);

        return abi.decode(data,(uint256));//这一步对应的是解码  (bool success,bytes memory data)  = _address.call(abi,encodeWithSignature("getx()"));

    }

    //定义一个不存在的函数来验证是否触发了fallback()
    function notexist(address _address) public{

        (bool  success,bytes memory data)  = _address.call(abi.encodeWithSignature("hahaha(uint256)"));

        emit repend(success,data);
        
    }


}