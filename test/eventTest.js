const { expect } = require("chai")
const { deployments, ethers, getNamedAccounts } = require("hardhat")

describe("this is second eventTest test", function () {
  let eventTest
  let eventTestDeployment
  let firstAccount

  beforeEach(async function () {
    // 1) 运行部署脚本（重置到干净状态）
    await deployments.fixture(["all"])


    // 3) 从 namedAccounts 拿到你配置的地址（如果你有配置）
    firstAccount = (await getNamedAccounts()).firstAccount

    // 4) 拿到 deployment 信息并用地址创建 ethers 合约实例
    eventTestDeployment = await deployments.get("eventTest")//返回合约所以信息
    eventTest = await ethers.getContractAt("eventTest", eventTestDeployment.address)/*“我知道你是谁（ABI）”
    “我知道你住哪里（address）”
    所以我现在能去敲你家门调函数了*/
  })

  it("test balance equal 0 for firstAccount", async function () {
    // 注意这里传入的是地址字符串，不是合约对象
    // 如果 namedAccounts 配置了 firstAccount 并且是有效地址，就用它；否则用 owner.address
    const addrToCheck = firstAccount 
    const balance = await eventTest._balance(addrToCheck) // returns BigNumber

    // 推荐的断言方式之一
    expect(balance.toString()).to.equal("0")

    // 或者
    // expect(balance).to.equal(ethers.BigNumber.from(0))
  })
})
