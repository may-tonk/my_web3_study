module.exports= async({getNamedAccounts,deployments})=>{
const {developmentChain} = require("../hlper-hardhat-config")

    const firstAccount = (await getNamedAccounts()).firstAccount
    const deploy = deployments.deploy//获取deployments中的deploy

    let dataFeedAddr
    let datafeedadd
    if(developmentChain.includes(network.name)/*本地网络*/){
       const dataFeedAddr = await deployments.get("MockV3Aggregator")
       const datafeedadd = dataFeedAddr.address
    }
    else{
        datafeedadd = ""
    }


    await deploy("eventTest",{
        from:firstAccount,
        args:[datafeedadd],//这个是地址datafeed
        log:true
    })



    //console.log(`firstAccount is ${firstAccount}`)
    
    //console.log(`this is a deploy contract functon`)
}

module.exports.tags=["all","eventTest"]