// 从 Hardhat 中导入 network 对象，用于获取当前网络信息（名称、chainId 等）
const { network } = require("hardhat");

// 导出一个部署函数，Hardhat-deploy 会自动调用
module.exports = async ({ getNamedAccounts, deployments, hre }) => {

    // 从 hlper-hardhat-config.js 中导入本地开发网络列表和网络配置
    const { developmentChain, networkConfig } = require("../hlper-hardhat-config");

    // 获取命名账户中的 firstAccount，通常是部署合约的默认账户
    const firstAccount = (await getNamedAccounts()).firstAccount;

    // 从 deployments 对象中获取 deploy 函数，用于部署合约
    const { deploy } = deployments; // 获取部署函数

    // 声明变量，用于存储数据源地址
    let dataFeedAddr;
    let datafeedadd;

    // 判断当前网络是否为本地开发网络
    if (developmentChain.includes(network.name)) {
        // 如果是本地网络，获取 MockV3Aggregator 的部署信息
        const dataFeedAddr = await deployments.get("MockV3Aggregator");

        // 将 MockV3Aggregator 的地址赋值给 datafeedadd，用于 FundMe 合约构造函数
        datafeedadd = dataFeedAddr.address;
    } else {
        // 如果是测试网或主网，从 networkConfig 中获取对应链的 Chainlink 数据源地址
        datafeedadd = networkConfig[network.config.chainId].ethUsdDataFeed;
    }

    // 可选：打印 datafeedadd 调试
    // console.log("Using price feed address:", datafeedadd);

    // 部署 FundMe 合约
    const fundMe = await deploy("fundme", {
        from: firstAccount,      // 部署账户
        args: [datafeedadd],     // 构造函数参数，传入 price feed 地址
        log: true                // 打印部署日志
    });

    // 如果部署到 Sepolia 测试网，并且环境变量中有 Etherscan API KEY，则自动验证合约
    if (hre.network.config.chainId == 11155111 && process.env.API_KEY) {
        console.log("Verifying contract on Etherscan...");

        // 调用 Hardhat 的 verify:verify 任务
        // 1. address: 使用 fundMe.address（注意之前使用 fundMe.target 是错误的）
        // 2. constructorArguments: 构造函数参数数组
        await hre.run("verify:verify", {
            address: fundMe.address,
            constructorArguments: [datafeedadd],
        });
    } else {
        // 如果不是 Sepolia 或没有 API KEY，则跳过 Etherscan 验证
        console.log(`skipping deploy sepolia network`);
    }

    // 可选调试：打印部署账户
    // console.log(`firstAccount is ${firstAccount}`);

    // 可选调试：提示这是一个部署函数
    // console.log(`this is a deploy contract function`);
};

// 为 Hardhat-deploy 添加标签
// 标签用于按组部署合约，例如 npx hardhat deploy --tags fundme
module.exports.tags = ["all", "fundme"];
