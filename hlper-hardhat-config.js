// 定义一个常量 DECIMAL，用于表示小数位数。
// 在加密货币或代币合约中，通常用 DECIMAL 来表示代币的小数精度。
// 例如 DECIMAL = 8 表示代币最小单位为 10^-8
const DECIMAL = 8

// 定义一个常量 INIT_VALUE，用于初始化某个数值。
// 这里的数值 300000000000 可能是用作代币的初始供应量或者脚本中需要使用的初始值。
// 注释中提到“使用脚本变量=====>mocak”，这里的 mocak 可能是作者标记的测试/占位变量名。
const INIT_VALUE = 300000000000 // 使用脚本变量=====>mocak

// 定义一个数组 developmentChain，用于存储开发环境的链名称。
// 当部署合约或者运行脚本时，可以通过判断当前网络是否在 developmentChain 中
// 来决定是否使用模拟链（如 Hardhat 或本地链）进行测试
const developmentChain = ["hardhat", "local"]

// 导出这些变量，使得其他模块或脚本可以通过 require 或 import 引用这些常量。
// 例如，在部署脚本或测试脚本中，可以直接使用 DECIMAL、INIT_VALUE、developmentChain

const networkConfig = {
    11155111:{
        ethUsdDataFeed:"0x1b44F3514812d835EB1BDB0acB33d3fA3351Ee43"
    }
}

module.exports = {
    DECIMAL,
    INIT_VALUE,
    developmentChain,
    networkConfig
}



