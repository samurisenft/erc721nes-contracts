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
//    const contract = await Test721.attach("0xE09bB83215843EB0B246F0296833E676bAE46Ec4");
  const contract = await Test721.attach("0x220BC1980Fc2251A6Dbf66F95a39da42534450b8");
  //trx = await contract.stake(0);
  //console.log(trx);

  let balance = await contract.getCurrentAdditionalBalance(0);
  console.log(balance);


  }
  
  main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });