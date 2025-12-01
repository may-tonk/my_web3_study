const hre = request("hardhst")

async function deploy_faucets(){

    const mydeploy = await hre.ethers.getContractFactory("faucet")

    const Mydeloy = await mydeploy.deploy()//暂时缺乏hey代币地址

}