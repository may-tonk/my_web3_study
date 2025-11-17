const hre = require("hardhat")

async function main(){ 

    const StringsLib = await hre.ethers.getContractFactory("Strings");
    const stringsLibrary = await StringsLib.deploy();
    await stringsLibrary.waitForDeployment();
    console.log("Strings deployed at:", stringsLibrary.target);
    //存在library的使用时一定要先部署library合约


    const LibraryContract = await hre.ethers.getContractFactory("_library", {
  libraries: {
    Strings: stringsLibrary.target/*告诉hardhat我的library的地址链在哪里你写了一个外部库 Strings。
就像你写了一个外部工具箱。

你主合约 _library 用了这个工具箱里的工具。

要部署主合约之前，必须告诉 Hardhat：

这个工具箱叫啥？ → Strings

这个工具箱放在哪里？ → stringsLibrary.target*/

  }
});


     const mycontract = await LibraryContract.deploy();

    await mycontract.waitForDeployment()
    console.log(`ok  ${mycontract.target}`)//打印当前合约地址

}

main().catch((error) => {
    console.error(error)//注意是error(error)
    process.exitCode = 1//有错误退出当前部署

})