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
  let owner;
  let addr1;
  let addr2;
  let addrs;
  
  beforeEach(async function () {
    [owner, addr1, addr2, ...addrs] = await ethers.getSigners();
    TokenFactory = await ethers.getContractFactory("ERC721NESTestBasicImpl");
    test721TokenBasic = await TokenFactory.deploy(10);    
  });

    it("BASIC IMPL calling mint should mint happy case", async function () {
      const trx = await test721TokenBasic.connect(addr1).mint(1);        
      const addr1Balance = await test721TokenBasic.balanceOf(addr1.address);
      
      expect(await addr1Balance.toNumber()).to.equal(1);
      expect(await test721TokenBasic.isStaked(0)).to.equal(false);
    });

    it("BASIC IMPL staking acrrues balance at correct rate when minting and then staking", async function () {
      await test721TokenBasic.connect(addr1).mint(1);
      const addr1Balance = await test721TokenBasic.balanceOf(addr1.address);

      expect(await addr1Balance.toNumber()).to.equal(1);
      expect(await test721TokenBasic.getStakingRewards(0)).to.equal(0);

      await test721TokenBasic.connect(addr1).stakeToken(0);
      await mineNBlocks(10);

      expect(await test721TokenBasic.getStakingRewards(0)).to.equal(100);

      await mineNBlocks(10);

      expect(await test721TokenBasic.getStakingRewards(0)).to.equal(200);

      await mineNBlocks(10);

      expect(await test721TokenBasic.getStakingRewards(0)).to.equal(300);
    });

    it("BASIC IMPL staking prevents transfer, unstakes allows transfer", async function () {
      const trx = await test721TokenBasic.connect(addr1).mint(1);
      let addr1Balance = await test721TokenBasic.balanceOf(addr1.address);
      let addr2Balance = await test721TokenBasic.balanceOf(addr2.address);

      expect(await addr1Balance.toNumber()).to.equal(1);
      expect(await addr2Balance.toNumber()).to.equal(0);

      const trx2 = await test721TokenBasic.connect(addr1).stakeToken(0);

      await expect(test721TokenBasic.transferFrom(addr1.address, addr2.address, 0)).to.be.revertedWith("You can not transfer a staked token");

      const trx3 = await test721TokenBasic.connect(addr1).unstakeToken(0);
      await test721TokenBasic.connect(addr1).transferFrom(addr1.address, addr2.address, 0);
      addr1Balance = await test721TokenBasic.balanceOf(addr1.address);
      addr2Balance = await test721TokenBasic.balanceOf(addr2.address);
      
      expect(await addr1Balance.toNumber()).to.equal(0);
      expect(await addr2Balance.toNumber()).to.equal(1);

    });

});  
