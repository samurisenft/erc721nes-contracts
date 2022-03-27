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

    TokenFactory = await ethers.getContractFactory("TestStakingController");
    testStakingController = await TokenFactory.deploy(test721Token.address, 1);    
    await test721Token.setStakingController(testStakingController.address);

  });

    it("calling mint and stake should mint happy case", async function () {
      const trx = await test721Token.connect(addr1).mint(1);        
      const addr1Balance = await test721Token.balanceOf(addr1.address);
      expect(await addr1Balance.toNumber()).to.equal(1);
      expect(await test721Token.isStaked(0)).to.equal(false);
    });

    it("staking acrrues balance at correct rate when minting and then staking", async function () {
      await test721Token.connect(addr1).mint(1);
      const addr1Balance = await test721Token.balanceOf(addr1.address);
      expect(await addr1Balance.toNumber()).to.equal(1);
      expect(await testStakingController.getStakingRewards(0)).to.equal(0);
      await testStakingController.connect(addr1).stake(0);
      await mineNBlocks(10);
      expect(await testStakingController.getStakingRewards(0)).to.equal(10);
      await mineNBlocks(10);
      expect(await testStakingController.getStakingRewards(0)).to.equal(20);
    });

    it("staking acrrues balance at correct rate when performing mintAndStake", async function () {
      console.log(`owner ${owner.address}`);
      await test721Token.connect(addr1).mintAndStake(2);
      const addr1Balance = await test721Token.balanceOf(addr1.address);
      expect(await addr1Balance.toNumber()).to.equal(2);
      // expect(await testStakingController.getStakingRewards(0)).to.equal(0);
      // expect(await testStakingController.getStakingRewards(1)).to.equal(0);
      // await mineNBlocks(10);
      // expect(await testStakingController.getStakingRewards(0)).to.equal(10);
      // expect(await testStakingController.getStakingRewards(1)).to.equal(20);
      // await mineNBlocks(10);
      // expect(await testStakingController.getStakingRewards(0)).to.equal(20);
      // expect(await testStakingController.getStakingRewards(1)).to.equal(20);
    });

    it("staking / unstaking from staking controller contract works", async function () {
      const trx = await test721Token.connect(addr1).mint(1);
      const addr1Balance = await test721Token.balanceOf(addr1.address);
      expect(await addr1Balance.toNumber()).to.equal(1);

      const trx2 = await testStakingController.connect(addr1).stake(0);
      await expect(test721Token.transferFrom(addr1.address, addr2.address, 0)).to.be.revertedWith("You can not transfer a staked token");
      const trx3 = await testStakingController.connect(addr1).unstake(0);
    });
});  
