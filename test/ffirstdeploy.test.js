const { expect } = require("chai")
const { ethers } = require("hardhat")

describe("test eventTest contract",async function() {
   let eventTest
   let owner
   let addr1
   let addr2
   beforeEach(async function(){
    [owner,addr1,addr2] = await ethers.getSigners()
    const EventTestFactory = await ethers.getContractFactory("eventTest")
    eventTest = await EventTestFactory.deploy()

    await eventTest.waitForDeployment()

   })

   it("初始合约余额应该是0",async function(){
    const balance = await eventTest._balance(owner.address)
    expect(balance).to.equal(0)

   })
}) 