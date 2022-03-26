// We import Chai to use its asserting functions here.
const Web3 = require("web3");
const { soliditySha3 } = require("web3-utils");
const { privateKeyServerSide, infuraProjectId, mnemonic, etherscanApiKey } = require('../secrets.json');
const { use, expect } = require("chai");
const { ethers } = require("hardhat");

async function mineNBlocks(n) {
  for (let index = 0; index < n; index++) {
    await ethers.provider.send('evm_mine');
  }
}

describe("Token contract", function () {
  let Token;
  let test721Token;
  let testStakingController;
  let owner;
  let addr1;
  let addr2;
  let addrs;
  
  beforeEach(async function () {
    TokenFactory = await ethers.getContractFactory("ERC721NESTestImpl");
    [owner, addr1, addr2, ...addrs] = await ethers.getSigners();

    test721Token = await TokenFactory.deploy();

    TokenFactory = await ethers.getContractFactory("TestStakingController");
    [owner, addr1, addr2, ...addrs] = await ethers.getSigners();

    test721Token = await TokenFactory.deploy();

    Token = await ethers.getContractFactory("TestStakingController");
    testStakingController = await Token.deploy(test721Token.address, 26);    
    await test721Token.setInternalStakingController(testStakingController.address);

  });



    it("calling allowlist mint and stake should mint happy case", async function () {
      const nonce = 0;
      const localHash = soliditySha3(addr1['address'] , nonce);
      
      console.log(`localHash: ${localHash}`);
      const signature = web3.eth.accounts.sign(localHash, privateKey)['signature'];

      console.log(`signature ${signature}`)
      const trx = await test721Token.connect(addr1).allowListMintAndStake(signature, nonce, {value: '47000000000000000' });
      
      const receipt = await trx.wait();
        
      const addr1Balance = await test721Token.balanceOf(addr1.address);
      expect(addr1Balance.toNumber()).to.equal(1);
      
    });

    it("staking acrrues balance at correct rate", async function () {
      const nonce = 0;
      const localHash = soliditySha3(addr1['address'] , nonce);
      
      console.log(`localHash: ${localHash}`);
      const signature = web3.eth.accounts.sign(localHash, privateKey)['signature'];

      console.log(`signature ${signature}`)
      const trx = await test721Token.connect(addr1).allowListMintAndStake(signature, nonce, {value: '47000000000000000' });
      
      const receipt = await trx.wait();
        
      const addr1Balance = await test721Token.balanceOf(addr1.address);
      expect(addr1Balance.toNumber()).to.equal(1);

      await mineNBlocks(26);
      expect(await testStakingController.getStakingRewards(0)).to.equal(1);
      await mineNBlocks(26);
      expect(await testStakingController.getStakingRewards(0)).to.equal(2);
      await mineNBlocks(26);
      expect(await testStakingController.getStakingRewards(0)).to.equal(3);
      await mineNBlocks(26);
      expect(await testStakingController.getStakingRewards(0)).to.equal(4);
      await mineNBlocks(26);
      expect(await testStakingController.getStakingRewards(0)).to.equal(5);
      await mineNBlocks(26);
      expect(await testStakingController.getStakingRewards(0)).to.equal(6);
      await mineNBlocks(26);
      expect(await testStakingController.getStakingRewards(0)).to.equal(7);
      await mineNBlocks(26);
      expect(await testStakingController.getStakingRewards(0)).to.equal(8);
      await mineNBlocks(26);
      expect(await testStakingController.getStakingRewards(0)).to.equal(9);
      await mineNBlocks(26);
      expect(await testStakingController.getStakingRewards(0)).to.equal(10);
      await mineNBlocks(26);
      expect(await testStakingController.getStakingRewards(0)).to.equal(11);
      await mineNBlocks(1);
      expect(await testStakingController.getStakingRewards(0)).to.equal(11);


    });

    it("staking / unstaking from staking controller contract works", async function () {
      const nonce = 0;
     
      const trx = await test721Token.connect(addr1).mint();
      const receipt = await trx.wait();
        
      const addr1Balance = await test721Token.balanceOf(addr1.address);
      expect(addr1Balance.toNumber()).to.equal(1);

      const trx2 = await testStakingController.connect(addr1).stake(0);

      await expect(test721Token.transferFrom(addr1.address, addr2.address, 0)).to.be.revertedWith("You can not transfer a staked token");

      const trx3 = await testStakingController.connect(addr1).unstake(0);
    });
    

  });  

});