// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/*
    Pair2：被工厂用 CREATE2 创建的 Pair 合约

    功能很简单：
    - 构造函数设置 factory（创建者）
    - initialize() 初始化两个 token 地址
*/
contract Pair2{

    address factory; // 记录是哪个工厂部署了这个 Pair2
    address token0;  // 排序后的 tokenA 与 tokenB 的较小者
    address token1;  // 排序后的 tokenA 与 tokenB 的较大者

    constructor(){
        // 构造函数会在部署 Pair2 时自动被执行
        // factory = msg.sender，代表“谁调用 new Pair2()”，谁就是工厂
        factory = msg.sender;
    }

    function initialize(address tokenA,address tokenB) public {
        // 限制：只有工厂（factory）能初始化 Pair2
        require(factory == msg.sender, "please check msg.sender or factory");

        // 存储排序后的 token 地址
        token0 = tokenA;
        token1 = tokenB;
    }
}


/*
    Factory 工厂合约：
    - 使用 CREATE2 创建 Pair2 合约
    - 计算 Pair2 的可预测地址
*/
contract Pairfactory{

    // getpair[token0][token1] = pair 地址
    mapping(address=>mapping(address=>address)) public getpair;

    // 存储所有 Pair2 合约地址
    address[] public allpair;

    /*
        使用 CREATE2 创建 Pair2

        1. 检查 token 不相同
        2. 排序（token0 < token1）
        3. 使用 token0 和 token1 生成 salt（CREATE2 的盐）
        4. new Pair2{salt: salt}()  使用 CREATE2 部署合约
        5. 初始化合约（pair.initialize）
        6. 存入映射与数组
    */
    function createpair(address _tokenA,address _tokenB) public  returns(address pairadd){

        // 要求 tokenA 与 tokenB 不能一样
        require(_tokenA != _tokenB, "error _tokenA==_tokenB");

        // 对 token 地址排序，保证 token0 < token1
        // 这非常重要，否则同一对 token 会重复部署两个 Pair
        (address token0,address token1) = _tokenA > _tokenB
            ? (_tokenA,_tokenB)
            : (_tokenB,_tokenA);
        
        // 使用 token0 + token1 计算盐（salt）
        // 注意 salt 必须唯一且可预测，这样才能生成可预测地址
        bytes32 salt = keccak256(abi.encodePacked(token0,token1));
    
        /*
            new Pair2{salt:salt}()
            这一行非常关键！

            - 使用 CREATE2 部署 Pair2
            - 部署者地址是 Pairfactory（address(this)）
            - 合约字节码是 Pair2 的 creationCode
            - salt 是你上面算的 salt

            这样 Pair2 的地址是可预测的！
        */
        Pair2 pair = new Pair2{salt:salt}();
        /*pair 是一个 Pair2 类型的变量

        Solidity 会自动把 new Pair2() 返回的地址存储在 pair 里

        所以 pair 实际上就是 新部署的 Pair2 合约地址*/

        // 初始化 Pair2，设置 token0 和 token1
        pair.initialize(token0,token1);

        // 保存部署出来的 Pair2 地址
        pairadd = address(pair);

        allpair.push(pairadd);  // 记录所有 Pair2
        getpair[token0][token1] = pairadd; // 正序
        getpair[token1][token0] = pairadd; // 反序
    }



    /*
        可预测地址计算函数 → 与 createpair() 的 CREATE2 逻辑完全一样

        输入：tokenA、tokenB
        输出：用 CREATE2 得到的未来 Pair2 合约地址（未部署也能算）
    */
    function calculateAddr(address tokenA, address tokenB) public view returns(address predictedAddress){

        require(tokenA != tokenB, 'IDENTICAL_ADDRESSES');

        // token 排序（与 createpair 保持一致）
        (address token0, address token1) = tokenA > tokenB
            ? (tokenA, tokenB)
            : (tokenB, tokenA);

        // 使用排序后的 token 计算与 createpair 完全相同的 salt
        bytes32 salt = keccak256(abi.encodePacked(token0, token1));
        
        /*
            CREATE2 生成地址的公式：

            address = keccak256(
                            0xff,
                            部署者地址（factory）
                            salt,
                            keccak256(要部署的合约字节码)
                        )[12:]

            ※注意※
            keccak256(type(Pair2).creationCode) 非常关键！
            因为你部署的是 Pair2 的字节码，而不是 Factory
        */

        bytes32 Hash = keccak256(
            abi.encodePacked(
                bytes1(0xff),             // 固定魔法字节
                address(this),            // 部署者（工厂地址）
                salt,                     // CREATE2 的盐
                keccak256(type(Pair2).creationCode) // Pair2 的初始化字节码哈希
            )
        );

        // 取最后 20 字节转成地址类型
        predictedAddress = address(uint160(uint256(Hash)));
    }
}
