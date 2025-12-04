// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// IERC721 基础接口
// ============ OpenZeppelin ERC721 核心接口 ============
import { IERC721 } from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import { IERC721Metadata } from "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import { IERC721Receiver } from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import { ERC721Utils } from "@openzeppelin/contracts/token/ERC721/utils/ERC721Utils.sol";

// ============ OpenZeppelin 通用工具 ============
import { Context } from "@openzeppelin/contracts/utils/Context.sol";
import { IERC165, ERC165 } from "@openzeppelin/contracts/utils/introspection/ERC165.sol";

// ============ OpenZeppelin 标准化错误接口 ============
import { IERC721Errors } from "@openzeppelin/contracts/interfaces/draft-IERC6093.sol";
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";
using Strings for uint256;




contract _ERC721 is IERC721, IERC721Metadata {

    // ============ 状态变量 ============

    // NFT 名称，例如 "MyNFT"
    string public override name;

    // NFT 符号，例如 "MNFT"
    string public override symbol;

    // tokenId 对应持有者地址
    mapping(uint => address) private _owners;

    // 持有者地址对应持有的 NFT 数量
    mapping(address => uint) private _balances;

    // tokenId 对应授权给的地址（可以操作该 token）
    mapping(uint => address) private _tokenApprovals;

    // 持有人地址对应操作员地址的授权状态
    // 如果 _operatorApprovals[owner][operator] = true，则 operator 可以操作 owner 的所有 NFT
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    // 错误定义：接收者无效（安全转账用）
    // 当使用 safeTransfer 时，如果接收合约不能处理 ERC721，会抛出这个错误
    error ERC721InvalidReceiver(address receiver);

    // ============ 构造函数 ============

    /**
     * @dev 构造函数，用于初始化 NFT 名称和代号
     * @param name_ NFT 名称
     * @param symbol_ NFT 代号
     */
    constructor(string memory name_, string memory symbol_) {
        name = name_;
        symbol = symbol_;
        // msg.sender 是部署合约的人
        // 通常会在 mint 或权限管理中使用 msg.sender
    }

    // ============ IERC165 接口 ============

    /**
     * @dev 查询合约是否支持某个接口
     * @param interfaceId 接口ID
     * @return bool 是否支持
     *
     * 小白理解：
     * ERC165 是标准接口检测协议，这里告诉外界：
     *   - 我支持 ERC721
     *   - 我支持 ERC721Metadata
     *   - 我支持 ERC165
     */
    function supportsInterface(bytes4 interfaceId)
        external
        pure
        override
        returns (bool)
    {
        return
            interfaceId == type(IERC721).interfaceId ||        // ERC721 基础接口
            interfaceId == type(IERC165).interfaceId ||       // ERC165 接口
            interfaceId == type(IERC721Metadata).interfaceId; // ERC721Metadata 接口
    }

    // ============ IERC721 查询函数 ============

    /**
     * @dev 查询账户持有的 NFT 数量
     * @param owner 查询的账户地址
     * @return uint 持有的 NFT 数量
     *
     * 小白理解：
     * 这个函数告诉你某个地址拥有多少个 NFT。
     * 如果地址是 0，直接报错，因为 0 号地址不能持有 NFT。
     */
    function balanceOf(address owner) external view override returns (uint) {
        require(owner != address(0), "owner = zero address");
        return _balances[owner];
    }

    /**
     * @dev 查询某个 tokenId 的拥有者
     * @param tokenId 查询的 tokenId
     * @return owner 拥有者地址
     *
     * 小白理解：
     * _owners 映射记录了每个 tokenId 对应的持有人地址。
     * 如果 tokenId 不存在，返回 0 地址，会报错。
     */
    function ownerOf(uint tokenId) public view override returns (address owner) {
        owner = _owners[tokenId];
        require(owner != address(0), "token doesn't exist");
    }

    /**
     * @dev 查询 owner 是否将 NFT 批量授权给 operator
     * @param owner 持有人地址
     * @param operator 授权操作员地址
     * @return bool 是否授权
     *
     * 小白理解：
     * 如果 owner 想让 operator 操作自己所有 NFT，就会设置这个映射为 true
     * operator 就可以不经过 owner 直接调用 transfer。
     */
    function isApprovedForAll(address owner, address operator)
        external
        view
        override
        returns (bool)
    {
        return _operatorApprovals[owner][operator];
    }

    // ============ IERC721 授权函数 ============

    /**
     * @dev 批量授权 operator 对 msg.sender 的所有 NFT 进行操作
     * @param operator 操作员地址
     * @param approved 是否授权
     *
     * 小白理解：
     * 这就是“我允许某人帮我操作我的所有 NFT”。
     * 如果 approved = true，operator 可以操作所有 NFT；false 就取消授权。
     */
    function setApprovalForAll(address operator, bool approved) external override {
        _operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    /**
     * @dev 查询某个 tokenId 的授权地址
     * @param tokenId 查询的 tokenId
     * @return address 授权地址
     *
     * 小白理解：
     * 这个函数告诉你，某个 NFT 当前被授权给谁，可以操作它。
     */
    function getApproved(uint tokenId) external view override returns (address) {
        require(_owners[tokenId] != address(0), "token doesn't exist");
        return _tokenApprovals[tokenId];
    }

    /**
     * @dev 内部函数：设置 tokenId 的授权地址
     * @param owner tokenId 所有者
     * @param to 授权给的地址
     * @param tokenId tokenId
     *
     * 小白理解：
     * _approve 就是“把某个 NFT 授权给某人操作”。
     * 这里只是改映射，然后发事件提醒外界。
     */
    function _approve(
        address owner,
        address to,
        uint tokenId
    ) private {
        _tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }

    /**
     * @dev 外部函数：将 tokenId 授权给 to 地址
     * 条件：to 不是 owner，msg.sender 是 owner 或 operator
     * @param to 授权地址
     * @param tokenId tokenId
     *
     * 小白理解：
     * 这个函数就是普通用户用的 approve
     * 如果你是 NFT 的持有人或者被批量授权的人，就可以授权别人操作这个 NFT。
     */
    function approve(address to, uint tokenId) external override {
        address owner = _owners[tokenId];
        require(
            msg.sender == owner || _operatorApprovals[owner][msg.sender],
            "not owner nor approved for all"
        );
        _approve(owner, to, tokenId);
    }

       // 查询 spender地址是否可以使用tokenId（需要是owner或被授权地址）
    function _isApprovedOrOwner(
        address owner,
        address spender,
        uint tokenId
    ) private view returns (bool) {
        return (spender == owner ||
            _tokenApprovals[tokenId] == spender ||
            _operatorApprovals[owner][spender]);
    }

        /*
     * 转账函数。通过调整_balances和_owner变量将 tokenId 从 from 转账给 to，同时释放Transfer事件。
     * 条件:
     * 1. tokenId 被 from 拥有
     * 2. to 不是0地址
     */
    function _transfer(
        address owner,
        address from,
        address to,
        uint tokenId
    ) private {
        require(from == owner, "not owner");
        require(to != address(0), "transfer to the zero address");

        _approve(owner, address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }
    
    // 实现IERC721的transferFrom，非安全转账，不建议使用。调用_transfer函数
    function transferFrom(
        address from,
        address to,
        uint tokenId
    ) external override {
        address owner = ownerOf(tokenId);
        require(
            _isApprovedOrOwner(owner, msg.sender, tokenId),
            "not owner nor approved"
        );
        _transfer(owner, from, to, tokenId);
    }

    /**
     * 安全转账，安全地将 tokenId 代币从 from 转移到 to，会检查合约接收者是否了解 ERC721 协议，以防止代币被永久锁定。调用了_transfer函数和_checkOnERC721Received函数。条件：
     * from 不能是0地址.
     * to 不能是0地址.
     * tokenId 代币必须存在，并且被 from拥有.
     * 如果 to 是智能合约, 他必须支持 IERC721Receiver-onERC721Received.
     */
    function _safeTransfer(
        address owner,
        address from,
        address to,
        uint tokenId,
        bytes memory _data
    ) private {
        _transfer(owner, from, to, tokenId);
        _checkOnERC721Received(from, to, tokenId, _data);
    }

    /**
     * 实现IERC721的safeTransferFrom，安全转账，调用了_safeTransfer函数。
     */
    function safeTransferFrom(
        address from,
        address to,
        uint tokenId,
        bytes memory _data
    ) public override {
        address owner = ownerOf(tokenId);
        require(
            _isApprovedOrOwner(owner, msg.sender, tokenId),
            "not owner nor approved"
        );
        _safeTransfer(owner, from, to, tokenId, _data);
    }

    // safeTransferFrom重载函数
    function safeTransferFrom(
        address from,
        address to,
        uint tokenId
    ) external override {
        safeTransferFrom(from, to, tokenId, "");
    }

    /** 
     * 铸造函数。通过调整_balances和_owners变量来铸造tokenId并转账给 to，同时释放Transfer事件。铸造函数。通过调整_balances和_owners变量来铸造tokenId并转账给 to，同时释放Transfer事件。
     * 这个mint函数所有人都能调用，实际使用需要开发人员重写，加上一些条件。
     * 条件:
     * 1. tokenId尚不存在。
     * 2. to不是0地址.
     */
    function _mint(address to, uint tokenId) internal virtual {
        require(to != address(0), "mint to zero address");
        require(_owners[tokenId] == address(0), "token already minted");

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);
    }

    // 销毁函数，通过调整_balances和_owners变量来销毁tokenId，同时释放Transfer事件。条件：tokenId存在。
    function _burn(uint tokenId) internal virtual {
        address owner = ownerOf(tokenId);
        require(msg.sender == owner, "not owner of token");

        _approve(owner, address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);
    }

    // _checkOnERC721Received：函数，用于在 to 为合约的时候调用IERC721Receiver-onERC721Received, 以防 tokenId 被不小心转入黑洞。
    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory data) private {
        if (to.code.length > 0) {
            try IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, data) returns (bytes4 retval) {
                if (retval != IERC721Receiver.onERC721Received.selector) {
                    revert ERC721InvalidReceiver(to);
                }
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert ERC721InvalidReceiver(to);
                } else {
                    /// @solidity memory-safe-assembly
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        }
    }

    /**
     * 实现IERC721Metadata的tokenURI函数，查询metadata。
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_owners[tokenId] != address(0), "Token Not Exist");

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }

    /**
     * 计算{tokenURI}的BaseURI，tokenURI就是把baseURI和tokenId拼接在一起，需要开发重写。
     * BAYC的baseURI为ipfs://QmeSjSinHpPnmXmspMjwiXyN6zS4E9zccariGR3jxcaWtq/ 
     */
    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }
}
