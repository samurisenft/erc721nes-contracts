const Web3 = require("web3");
const { soliditySha3 } = require("web3-utils");
const { privateKeyServerSide, infuraProjectId, mnemonic, etherscanApiKey } = require('../secrets.json');
const { use, expect } = require("chai");
const { ethers } = require("hardhat");

async function main() {
    const [deployer] = await ethers.getSigners();
    var web3 = new Web3('https://rinkebys.infura.io/v3/908e29044bcc435e9183aae2ba70e625'); // your geth
    console.log("Deploying contracts with the account:", deployer.address);
    const Test721 = await ethers.getContractFactory("Test721");
    const contract = await Test721.attach("0xE09bB83215843EB0B246F0296833E676bAE46Ec4");
  
    
    //let trx = await contract.unpause();
    //console.log(trx);

    const sig = '0x2f87a2ef76a3389f3b95da865be8667fe53d956a';

    trx = await contract.setSignatureVerifier(sig);
    console.log(trx);

    
    const nonce = 0;
    const localHash = soliditySha3(deployer['address'] , nonce);
    
    console.log(`localHash: ${localHash}`);
    const signature = web3.eth.accounts.sign(localHash, privateKeyServerSide)['signature'];
    
    console.log(`signature ${signature}`)
    trx = await contract.allowListMint(signature, nonce, {value: '47000000000000000' });
    console.log(trx);
    const receipt = await trx.wait();

    console.log(receipt);

    // const nonce = 0;
    // const localHash = soliditySha3(deployer['address'] , nonce);
    
    // console.log(`localHash: ${localHash}`);
    // const signature = web3.eth.accounts.sign(localHash, privateKeyServerSide)['signature'];

    // console.log(`signature ${signature}`)
    // const trx4 = await contract.allowListMintAndStake(signature, nonce, {value: '47000000000000000' });
    // console.log(trx4);

    
    trx = await contract.stake(0);
    console.log(trx);

    let balance = await contract.getStakedCumulativeBalance(0);
    console.log(balance);


  }
  
  main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });