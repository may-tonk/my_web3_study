// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/*
  Faucet（水龙头）合约功能说明：
  - 用户可以按固定数量领取 ERC20 代币
  - 支持领取冷却时间（cooldown）
  - 仅使用 SafeERC20 保证兼容多数 ERC20
  - 管理员（Owner）可修改领取数量、冷却时间、回收代币、重置领取时间
*/

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Faucets is Ownable {
    using SafeERC20 for IERC20;

    /// 每次允许领取的 token 数量（以最小单位为准，例如 100 * 10**18）
    uint256 public amountAllowed;

    /// 两次领取之间的冷却时间（单位：秒）
    uint256 public cooldown;

    /// 记录每个用户上次领取时间戳
    mapping(address => uint256) public lastRequestTime;

    /// ERC20 代币合约地址（immutable：部署后不可变）
    IERC20 public immutable token;

    // 事件记录关键操作
    event CooldownUpdated(uint256 oldCooldown, uint256 newCooldown);
    event AmountAllowedUpdated(uint256 oldAmount, uint256 newAmount);
    event SendToken(address indexed receiver, uint256 amount);

    /**
     * @param _token ERC20 代币合约地址
     * @param _amountAllowed 每次领取数量
     * @param _cooldown 两次领取间隔时间（秒）
     */
    constructor(address _token, uint256 _amountAllowed, uint256 _cooldown) 
        Ownable(msg.sender) // 部署者成为管理员
    {
        require(_token != address(0), "token address zero");

        token = IERC20(_token);
        amountAllowed = _amountAllowed;
        cooldown = _cooldown;
    }
    /*_token 只是 告诉 Faucet 合约哪个 ERC20 合约是它要发的代币

它并不会自动给 Faucet 合约发送代币

token 变量只是 一个指向 ERC20 合约的接口，方便你调用 transfer 或 balanceOf*/

    /**
     * @notice 用户请求领取代币
     * - 检查冷却时间
     * - 检查 faucet 是否有足够余额
     * - 更新 lastRequestTime
     * - 发放代币
     */
    function requestToken() external {
        uint256 last = lastRequestTime[msg.sender];
        require(block.timestamp >= last + cooldown, "please patiently wait");

        uint256 balance = token.balanceOf(address(this));
        require(balance >= amountAllowed, "faucet balance insufficient");

        // 更新领取时间
        lastRequestTime[msg.sender] = block.timestamp;

        // 发放代币
        token.safeTransfer(msg.sender, amountAllowed);

        emit SendToken(msg.sender, amountAllowed);
    }

    /* ========== 管理员操作函数 ========== */

    /// 修改冷却时间
    function updateCooldown(uint256 _newCooldown) external onlyOwner {
        uint256 oldCooldown = cooldown;
        cooldown = _newCooldown;

        emit CooldownUpdated(oldCooldown, _newCooldown);
    }

    /// 修改每次领取的数量
    function updateAmountAllowed(uint256 _newAmount) external onlyOwner {
        uint256 oldAmount = amountAllowed;
        amountAllowed = _newAmount;

        emit AmountAllowedUpdated(oldAmount, _newAmount);
    }

    /// 管理员回收合约内代币
    function withdrawTokens(address _to, uint256 _amount) external onlyOwner {
        require(_to != address(0), "invalid recipient");
        token.safeTransfer(_to, _amount);

        emit SendToken(_to, _amount);
    }

    /// 管理员重置某个用户的领取时间（例如用于补发）
    function resetLastRequestTime(address _user) external onlyOwner {
        lastRequestTime[_user] = 0;
    }

    /// 查询合约内 token 余额
    function faucetBalance() external view returns (uint256) {
        return token.balanceOf(address(this));
    }
}


