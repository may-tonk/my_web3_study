module.exports= async({getNamedAccounts,deployments})=>{


    const firstAccount = (await getNamedAccounts()).firstAccount

    console.log(`firstAccount is ${firstAccount}`)
    
    console.log(`this is a deploy contract functon`)
}