const {ContractFactory, utils} = require('ethers');
const {MockProvider} = require('@ethereum-waffle/provider');
const {waffleChai} = require('@ethereum-waffle/chai');
const {deployMockContract} = require('@ethereum-waffle/mock-contract');
const { use } = require('chai');

use(waffleChai)

async function main() {
    const [deployer] = await ethers.getSigners();
  
    console.log("Deploying contracts with the account:", deployer.address);
    console.log("Account balance:", (await deployer.getBalance()).toString());
    const ERC721NESTestImpl = await ethers.getContractFactory("ERC721NESTestImpl");
    const erc721NESTestImpl = await ERC721NESTestImpl.deploy();
    console.log("Token address:", erc721NESTestImpl.address);
    const contract = await eRC721NESTestImpl.attach(eRC721NESTestImpl.address);
    
    const trx2 = await contract.setSignatureVerifier("0x2f87a2ef76a3389f3b95da865be8667fe53d956a");
    console.log(trx2);

  }
  
  main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });