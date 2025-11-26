const {DEMICAL,INIT_VALUE} = require("../hlper-hardhat-config")

module.exports= async({getNamedAccounts,deployments})=>{


    const firstAccount = (await getNamedAccounts()).firstAccount
    const deploy = deployments.deploy//获取deployments中的deploy

    await deploy("MockV3Aggregator",{
        from:firstAccount,
        args:[DEMICAL,INIT_VALUE],
        log:true
    })



    //console.log(`firstAccount is ${firstAccount}`)
    
    //console.log(`this is a deploy contract functon`)
}

module.exports.tags=["all","mock"]