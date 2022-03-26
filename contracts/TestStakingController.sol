// SPDX-License-Identifier: MIT
// Creator: base64.tech
pragma solidity ^0.8.9;

import "./ERC721NES.sol";

/**
 *  @dev This is a sample implementation of a staking controller use in conjunction with
 *  an contract that implements ERC721NES. 
 *  
 *  This implementation captures the total duration staked for a given token either by
 *  block.timestamp or by block.number and provides a divisor to convert this value
 *  to a balance.
 */
contract TestStakingController {
    
    // Address of the ERC721 token contract
    address tokenContract;
    // Divisor to determine the balance to accrue during the
    // duration staked.
    uint256 divisor;
    // This bool is utilized to determine whether token balance is 
    // calculated based off of block.number or block.timestamp.
    // Defaults to block.number.
    bool private blockNumberBased = true;

    // For each token, this map stores the current block.number or block.timestamp
    // if token is mapped to 0, it is currently unstaked.
    mapping(uint256 => uint256) public tokenToWhenStaked;

    // For each token, this map stores the total duration staked 
    // measured by block.number or block.timestamp.
    mapping(uint256 => uint256) public tokenToTotalDurationStaked;
    
    /**
     *  @dev constructor 
     */
     constructor(address _tokenContract, uint256 _divisor, bool _blockNumberBased) {
        tokenContract = _tokenContract;
        divisor = _divisor;
        blockNumberBased = _blockNumberBased;
    }

     /**
     *  @dev sets setBlockNumberBased, scope of this method is internal, so this defaults
     *  to requiring setting the the duration accounting method upon deployment or requires 
     *  a a public OnlyOwner helper method to be exposed in the implementing contract.
     */
    function _setBlockNumberBased(bool _blockNumberBased) internal {
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
     *  @dev returns total duration the token has been staked.
     */
    function getCumulativeDurationStaked(uint256 tokenId) public view returns (uint256){
        return tokenToTotalDurationStaked[tokenId] + getCurrentAdditionalBalance(tokenId);
    }

    /**
     *  @dev Returns the amount of tokens rewarded up until this point.
     */
    function getStakingRewards(uint256 tokenId) public view returns(uint256) { 
        return ERC721NES(tokenContract).getCumulativeDurationStaked(tokenId) / divisor; // allows for toke accumulation at ~ 10 per hour
    }

    /**
     *  @dev Stakes a token and records the start block number or time stamp.
     */
    function stake(uint256 tokenId) public {
        require(ERC721NES(tokenContract).ownerOf(tokenId) == msg.sender, "You are not the owner of this token");
        
        tokenToIsStaked[tokenId] = getBlockNumberOrTimeStamp();
        ERC721NES(tokenContract).stake(tokenId, msg.sender);
    }

    /**
     *  @dev Unstakes a token and records the start block number or time stamp.
     */
    function unstake(uint256 tokenId) public {
        require(ERC721NES(tokenContract).ownerOf(tokenId) == msg.sender, "You are not the owner of this token");

        tokenToTotalDurationStaked[tokenId] += getCurrentAdditionalBalance(tokenId);
        ERC721NES(tokenContract).unstake(tokenId, msg.sender);
    }
}