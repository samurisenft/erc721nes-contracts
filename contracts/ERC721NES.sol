// SPDX-License-Identifier: MIT
// Creator: base64.tech

pragma solidity ^0.8.9;

import './ERC721A.sol';
import "hardhat/console.sol";

/**
 *  @dev Extension of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard,
 *  that allows for Non Escrow Staking. By calling the staking operation on a token, you disable 
 *  the ability to transfer the token. The duration a token is staked is stored and can be utilized 
 *  to facilitate functional logic around rewards granted for staking.
 *  
 *  This implementation extends ERC721A, but can be modified to extend your own ERC721 implementation 
 *  or the standard Open Zeppelin version.
 */ 
abstract contract ERC721NES is ERC721A {
    
    // This is an optional reference to an external contract allows
    // you to abstract away your staking interface to another contract.
    address stakingController;
      
    // For each token, this map stores the current block.number or block.timestamp
    // if token is mapped to 0, it is currently unstaked.
    mapping(uint256 => uint256) public tokenToWhenStaked;

    // For each token, this map stores the total duration staked 
    // measured by block.number or block.timestamp.
    mapping(uint256 => uint256) public tokenToTotalDurationStaked;
    
    // This bool is utilized to determine whether token balance is 
    // calculated based off of block.number or block.timestamp.
    // Defaults to block.number.
    bool private blockNumberBased = true;

    /**
     *  @dev sets stakingController, scope of this method is internal, so this defaults
     *  to requiring setting the staking controller contact upon deployment or requires 
     *  a public OnlyOwner helper method to be exposed in the implementing contract.
     */
    function setStakingController(address _stakingController) internal {
        stakingController = _stakingController;
    }

    /**
     *  @dev sets setBlockNumberBased, scope of this method is internal, so this defaults
     *  to requiring setting the the duration accounting method upon deployment or requires 
     *  a a public OnlyOwner helper method to be exposed in the implementing contract.
     */
    function setBlockNumberBased(bool _blockNumberBased) internal {
        blockNumberBased = _blockNumberBased;
    }

    /**
     *  @dev utility method to provide block.number or block.timestamp
     */
    function getBlockNumberOrTimeStamp() private view returns (uint256) {
        return (blockNumberBased == true ? block.number: block.timestamp);
    }

    /**
     *  @dev returns the additional balance between when token was staked until now
     */
    function getCurrentAdditionalBalance(uint256 tokenId) public view returns (uint256) {
        return  getBlockNumberOrTimeStamp() - tokenToWhenStaked[tokenId];
    }

    /**
     *  @dev returns total duration the token has been staked
     */
    function getCumulativeDurationStaked(uint256 tokenId) public view returns (uint256){
        return tokenToTotalDurationStaked[tokenId] + getCurrentAdditionalBalance(tokenId);
    }

    /**
     *  @dev returns whether a token is currently staked
     */
    function isStaked(uint256 tokenId) public view returns (bool) {
        return tokenToWhenStaked[tokenId] != 0;
    }

    /**
     *  @dev marks a token as staked, can only be performed by token holder or 
     *  delegated staking controller contract. By calling this function
     *  you disable the ability to transfer the token.
     */
    function stake(uint256 tokenId, address originator) public {
        require(ownerOf(tokenId) == msg.sender || (ownerOf(tokenId) == originator && msg.sender == stakingController), "Originator is not the owner of this token");
        require(!isStaked(tokenId), "token is already staked");
        tokenToWhenStaked[tokenId] = getBlockNumberOrTimeStamp();
    }

    /**
     *  @dev marks a token as unstaked, can only be performed by token holder or 
     *  delegated staking controller contract. By calling this function
     *  you re-enable the ability to transfer the token.
     */
    function unstake(uint256 tokenId, address originator) public {
        require(ownerOf(tokenId) == msg.sender || (ownerOf(tokenId) == originator && msg.sender == stakingController), "Originator is not the owner of this token");
        require(isStaked(tokenId), "token isn't staked");
        
        tokenToTotalDurationStaked[tokenId] += getCurrentAdditionalBalance(tokenId);
        tokenToWhenStaked[tokenId] = 0; // setting to 0 indicates a token is unstaked
    }

    /**
     *  @dev perform safe mint and stake
     */
    function _safemintAndStake(address to, uint256 quantity) internal {
        uint256 startTokenId = _currentIndex;
 
        for(uint256 i = 0; i < quantity; i++){
            startTokenId++;
            tokenToWhenStaked[startTokenId] = getBlockNumberOrTimeStamp();
        }
        _safeMint(to, quantity, '');
    }

    /**
     *  @dev perform mint and stake
     */
    function _mintAndStake(address to, uint256 quantity) internal {
        uint256 startTokenId = _currentIndex;
 
        for(uint256 i = 0; i < quantity; i++){
            startTokenId++;
            tokenToWhenStaked[startTokenId] = getBlockNumberOrTimeStamp();
        }
        _mint(to, quantity, '', false);
    }

    /**
     * @dev overrides transferFrom to prevent transfer if token is staked
     */
    function transferFrom(address from, address to, uint256 tokenId) public override {
        require(isStaked(tokenId) == false, 'You can not transfer a staked token');
        super.transferFrom(from, to, tokenId);
    }

    /**
     * @dev overrides safeTransferFrom to prevent transfer if token is staked
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) public override {
        require(isStaked(tokenId) == false, 'You can not transfer a staked token');
        super.safeTransferFrom(from, to, tokenId, '');
    }

    /**
     * @dev overrides safeTransferFrom to prevent transfer if token is staked
     */
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public  override {
        require(isStaked(tokenId) == false, 'You can not transfer a staked token');
        super.safeTransferFrom(from, to, tokenId, _data);
    }

}
