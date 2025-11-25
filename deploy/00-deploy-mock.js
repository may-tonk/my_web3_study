module.exports= async({getNamedAccounts,deployments})=>{


    const firstAccount = (await getNamedAccounts()).firstAccount
    const deploy = deployments.deploy//获取deployments中的deploy

    await deploy("AggregatorV3Interface",{
        from:firstAccount,
        args:[8,300000000000],
        log:true
    })



    //console.log(`firstAccount is ${firstAccount}`)
    
    //console.log(`this is a deploy contract functon`)
}

module.exports.tags=["all","mock"]