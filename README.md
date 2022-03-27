#About this project

ERC-721 NES, or Non Escrow Staking, is a novel implementation of a staking model that does not require the owner of a token to lock it into an escrow contract. What that means is the token never moves during the staking process, unlike traditional protocols where you receive a coupon to then redeem later for your staked tokens. Instead, the token is flagged as non transferrable for the entire staking duration. In this way, the owner of a token has zero exposure to the risk of a staking protocol being compromised and their tokens stolen.

If a protocol is not using your token to create some sort of financial derivative, it has no business in having the permission of ownership over it.

Our hypothesis is that this distinction is an important one for blockchain gaming. As a token grows in value, the token owner is inversely incentivized for engagement: their token is locked in an escrow contract that could potentially lose their token in the case of faulty code.

NES also offers other ancillary advantages, like being able to receive purchase offers on tokens from various marketplaces or being able to easily prove ownership of a token for things like Collab.Land, Premint or Twitter.

#Implementation

ERC-721 NES provides an interface to staking protocols by decorating the prototypical ERC-721 contract with a few additional methods and maintaining one new piece of state. Now, instead of a custodial approach where the owner relinquishes all the power over their token, a signal based locking mechanism can be employed.

```
stake(uint256 tokenId)
// locks the token

unstake(uint256 tokenId)
// unlocks the token

isStaked(uint256 tokenId)
// returns a boolean indicating the staked status of the token

address stakingController
// address of the staking contract
```

#Getting Started
##Integrate
- Install ERC-721 NES as a dependency via NPM

```npm install @samurise/erc721nes```

- Extend your ERC-721 contract using ERC721NES

```
import "@samurise/erc721nes/ERC721NES.sol";

contract MyNFT is ERC721NES {
  // your ERC-721 code here
}
```

Contribute
We are always eager to improve and adopt new ideas, please feel free to make suggestions by raising a pull request.