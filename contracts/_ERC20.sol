// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/*
  这个合约实现了ERC20接口，允许铸造(mint)、销毁(burn)代币。
  注意：当前mint/burn没有权限控制，生产环境请加onlyOwner。
*/

contract mycontract is IERC20 {

    // 地址 => 余额
    mapping(address => uint256) public override balanceOf;

    // 地址 => (授权地址 => 授权额度)
    mapping(address => mapping(address => uint256)) public override allowance;

    // 总供应量
    uint256 public override totalSupply;

    // 代币名字
    string public name;

    // 代币符号
    string public symbol;

    // 小数位，ERC20标准是 decimals
    uint8 public decimals = 18;

    // 构造函数，部署合约时设置代币名称和符号
    constructor(string memory _name,string memory _symbol){
        name = _name;
        symbol = _symbol;
    }

    // 转账函数，把自己账户的代币转给其他人
    function transfer(address to, uint256 value) public override returns (bool){
        // 检查余额是否足够
        require(balanceOf[msg.sender] >= value, "ERC20: insufficient balance");
        // 扣除发送者余额
        balanceOf[msg.sender]-= value;
        // 增加接收者余额
        balanceOf[to]+=value;
        // 发事件，让前端或钱包监听
        emit Transfer(msg.sender,to,value);
        return true;  
    }

    // 授权函数，允许 spender 花费自己账户的代币
    function approve(address spender, uint256 value) public override returns (bool){
        allowance[msg.sender][spender]=value;
        emit Approval(msg.sender,  spender,  value);
        return true;
    }

    // 从授权账户转账给其他账户
    function transferFrom(address from, address to, uint256 value) public override returns (bool){
        // 检查余额
        require(balanceOf[from] >= value, "ERC20: insufficient balance");
        // 检查授权额度
        require(allowance[from][msg.sender] >= value, "ERC20: allowance exceeded");
        // 扣除余额
        balanceOf[from]-=value;
        // 增加接收者余额
        balanceOf[to]+=value;
        // 扣除授权额度
        allowance[from][msg.sender]-=value;
        // 发事件
        emit Transfer(from,to,value);
        return true;
    }

    // 增发代币，代币会给调用者
    function mint(uint256 value) public returns(bool){
        balanceOf[msg.sender]+=value;
        totalSupply+=value;
        emit Transfer(address(0),msg.sender,value);
        return true;
    }

    // 销毁代币，从调用者余额减少
    function burn(uint256 value) public  returns(bool){
        require(balanceOf[msg.sender] >= value, "ERC20: insufficient balance");
        balanceOf[msg.sender]-=value;
        totalSupply-=value;
        emit Transfer(msg.sender,address(0),value);
        return true;
    }

}

//msg.sender是外部调用的地址,并不是合约地址

