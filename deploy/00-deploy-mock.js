// 从 hlper-hardhat-config.js 中导入三个常量
// DECIMAL: MockV3Aggregator 模拟合约的小数位数
// INIT_VALUE: 模拟合约的初始数值
// developmentChain: 本地开发网络的名称数组，如 ["hardhat", "local"]
const { DECIMAL, INIT_VALUE, developmentChain } = require("../hlper-hardhat-config");

// 导出一个部署函数，Hardhat-deploy 会自动调用
module.exports = async ({ getNamedAccounts, deployments, network }) => {

    // 获取命名账户中的 firstAccount 地址，通常是部署合约的默认账户
    const { firstAccount } = await getNamedAccounts();

    // 从 deployments 对象中获取 deploy 函数，用于部署合约
    const { deploy } = deployments; // 获取部署函数

    // 判断当前网络是否属于本地开发网络
    if (developmentChain.includes(network.name)) {
        // 如果是本地网络，则部署 MockV3Aggregator 模拟合约
        // 这里传入构造函数参数 args:
        // [DECIMAL, INIT_VALUE] 分别是小数位数和初始价格值
        await deploy("MockV3Aggregator", {
            from: firstAccount,    // 部署合约的账户
            args: [DECIMAL, INIT_VALUE], // 构造函数参数
            log: true              // 在控制台打印部署日志
        });

    } else {
        // 如果不是本地网络（例如测试网或主网），跳过部署 Mock 合约
        console.log(`skipping local network`);
    }

    // 可选调试：打印部署账户地址
    // console.log(`firstAccount is ${firstAccount}`);

    // 可选调试：提示这是一个部署函数
    // console.log(`this is a deploy contract function`);
};

// 为 Hardhat-deploy 添加标签
// 标签用于按组部署合约，例如 npx hardhat deploy --tags mock
module.exports.tags = ["all", "mock"];
