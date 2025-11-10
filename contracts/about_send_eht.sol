//SPDX-License-Identifier:MIT
pragma solidity ^0.8.24;

contract fundeth{
    address public owner;//先定义发送者的地址，为了好撤回


    constructor() payable{
         owner = msg.sender;

    }

    error sb();

    mapping(address=>uint256) public listeth; //进行mapping存相应的地址和资金并且listeth不可以声明为数组

    address[] public people;

    function fundmoney() public payable{
        require(msg.value>1,"please confirm ,Him need 1 eth");
        people.push(msg.sender);//类似于c++中的压载
        listeth[msg.sender]+=msg.value;//映射相应的值
        }

    function fundhim() public onlyowner{
        
        for(uint256 _ad1 = 0;_ad1<people.length;_ad1++){
            address peopleaddress = people[_ad1];//接受当前地址

            uint256 amountsecond = listeth[peopleaddress];//一步一步的清理余额

                if(amountsecond == 0){
                    continue;
                }
            
            listeth[peopleaddress] = 0;

            (bool success,) = payable(msg.sender).call{value:amountsecond}("");//使用call进行转账
            require(success,"haha please send once again");   
            }

        }

        modifier onlyowner {//对于请求返回资金的地址进行验证是否是msg.sender
            if(owner!=msg.sender){
                revert ("sb");
                }
            _;
        }

        function retireve() public view returns(uint256 num){//检查发送者的资金
            num=msg.sender.balance;

        }

        function secondretrieve(address contractsnow) public view returns(uint256 number){//检查当前合约地址的资金
             number = contractsnow.balance;
        }


    receive() external payable{ //在msg.data是空的时候调用，也就是有人直接向该合约地址转账
        fundmoney();
        }
    fallback() external payable{//有msg.data时用或者在面msg.data为空且没有receive()时使用
        fundmoney();
        }
}