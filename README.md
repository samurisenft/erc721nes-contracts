![ERC-721 NES Tests](https://github.com/samurisenft/erc721nes-contracts/actions/workflows/tests.yml/badge.svg)

# About this project

ERC-721 NES, or Non Escrow Staking, is a novel implementation of a staking model that does not require the owner of a token to lock it into an escrow contract. What that means is the token never moves during the staking process, unlike traditional protocols where you receive a coupon to then redeem later for your staked tokens. Instead, the token is flagged as non transferrable for the entire staking duration. In this way, the owner of a token has zero exposure to the risk of a staking protocol being compromised and their tokens stolen.

If a protocol is not using your token to create some sort of financial derivative, it has no business in having the permission of ownership over it.

Our hypothesis is that this distinction is an important one for blockchain gaming. As a token grows in value, the token owner is inversely incentivized for engagement: their token is locked in an escrow contract that could potentially lose their token in the case of faulty code.

NES also offers other ancillary advantages, like being able to receive purchase offers on tokens from various marketplaces or being able to easily prove ownership of a token for things like Collab.Land, Premint or Twitter.

# Implementation

ERC-721 NES provides an interface to staking protocols by decorating the prototypical ERC-721 contract with a few additional methods and maintaining one new piece of state. Now, instead of a custodial approach where the owner relinquishes all the power over their token, a signal based locking mechanism can be employed.

```
_stake(uint256 tokenId)
// locks the token

_unstake(uint256 tokenId)
// unlocks the token

isStaked(uint256 tokenId)
// returns a boolean indicating the staked status of the token

address stakingController
// address of the staking contract
```

# Getting Started

## Integrate
- Install ERC-721 NES as a dependency via NPM  
  ```
  npm install erc721nes
  ```

- Extend your ERC-721 contract using ERC721NES  
  ```
  import "erc721nes/ERC721NES.sol";
  
  contract MyNFT is ERC721NES {
    // your ERC-721 code here
  }
  ```

# Building and Installing Locally
1. Fork the repo 
2. git clone [your fork url]
3. Star the project ;-)
4. Run these command locally:
```
npm install
npx hardhat test
```

# Contribute
We are always eager to improve and adopt new ideas, please feel free to make suggestions by raising a pull request.

1. Fork the Project
2. Create your Feature Branch (git checkout -b feature/AmazingFeature)
3. Commit your Changes (git commit -m 'Add some AmazingFeature')
4. Push to the Branch (git push origin feature/AmazingFeature)
5. Open a Pull Request

# Other Non Custodial Staking Implementations 

## LockRegistry

- **Author**  
  [OwlOfMoistness](https://twitter.com/OwlOfMoistness)
- **Description**  
  Provides a really cool abstraction for non-custodial staking with multiple staking instances. It also paves the way for Owl's on-chain "2FA" concept, which is potentially groundbreaking for improving user security.
- **Source**  
  https://github.com/OwlOfMoistness/erc721-lock-registry

## SmolSchool

- **Author**  
  [SmolVerse](https://www.smolverse.lol/)
- **Description**  
  AFAIK, one of the first implementations of a "non-custodial staking" that we've found. This pattern continues to be adopted across the Treasure Ecosystem, and can be found in Bridgeworld's Legions as well.
- **Source**  
  https://arbiscan.io/address/0x6325439389e0797ab35752b4f43a14c004f22a9c#code
