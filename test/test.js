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
  let hardhatToken;
  let owner;
  let addr1;
  let addr2;
  let addrs;
  let privateKey = privateKeyServerSide;
  
  var web3 = new Web3('https://mainnet.infura.io/v3/908e29044bcc435e9183aae2ba70e625'); // your geth

  beforeEach(async function () {
    // Get the ContractFactory and Signers here.
    Token = await ethers.getContractFactory("Test721");
    [owner, addr1, addr2, ...addrs] = await ethers.getSigners();

    hardhatToken = await Token.deploy();
    await hardhatToken.setSignatureVerifier('0x2f87a2ef76a3389f3b95da865be8667fe53d956a');

    await hardhatToken.unpause();
  });

   describe("Transactions", function () {
    it("calling hash method matches calling it from server side", async function () {
      //const localHash = web3.eth.accounts.sign(owner['address'] + '0', privateKey)['signature'];
      const localHash = soliditySha3("\x19Ethereum Signed Message:\n32", soliditySha3(owner['address'] , 0));

      const hash = await hardhatToken.hashMessage(owner['address'], 0);

      expect(hash).to.equal(localHash);
    });

    it("calling allowlist mint should mint happy case", async function () {
      const nonce = 0;
      const localHash = soliditySha3(addr1['address'] , nonce);
      
      console.log(`localHash: ${localHash}`);
      const signature = web3.eth.accounts.sign(localHash, privateKey)['signature'];

      console.log(`signature ${signature}`)
      const trx = await hardhatToken.connect(addr1).allowListMint(signature, nonce, {value: '47000000000000000' });
      
      const receipt = await trx.wait();
        
      const addr1Balance = await hardhatToken.balanceOf(addr1.address);
      expect(addr1Balance.toNumber()).to.equal(1);
      
    });


    it("calling allowlist mint and stake should mint happy case", async function () {
      const nonce = 0;
      const localHash = soliditySha3(addr1['address'] , nonce);
      
      console.log(`localHash: ${localHash}`);
      const signature = web3.eth.accounts.sign(localHash, privateKey)['signature'];

      console.log(`signature ${signature}`)
      const trx = await hardhatToken.connect(addr1).allowListMintAndStake(signature, nonce, {value: '47000000000000000' });
      
      const receipt = await trx.wait();
        
      const addr1Balance = await hardhatToken.balanceOf(addr1.address);
      expect(addr1Balance.toNumber()).to.equal(1);
      
    });

    it("staking acrrues balance at correct rate", async function () {
      const nonce = 0;
      const localHash = soliditySha3(addr1['address'] , nonce);
      
      console.log(`localHash: ${localHash}`);
      const signature = web3.eth.accounts.sign(localHash, privateKey)['signature'];

      console.log(`signature ${signature}`)
      const trx = await hardhatToken.connect(addr1).allowListMintAndStake(signature, nonce, {value: '47000000000000000' });
      
      const receipt = await trx.wait();
        
      const addr1Balance = await hardhatToken.balanceOf(addr1.address);
      expect(addr1Balance.toNumber()).to.equal(1);

      await mineNBlocks(26);
      //expect(await hardhatToken.getCurrentAdditionalBalance(0)).to.equal(1);
      expect(await hardhatToken.getStakedCumulativeBalance(0)).to.equal(1);
      await mineNBlocks(260-26);
      expect(await hardhatToken.getStakedCumulativeBalance(0)).to.equal(10);
      await mineNBlocks(10);
      expect(await hardhatToken.getStakedCumulativeBalance(0)).to.equal(10);
    });


  });  

});