// SPDX-License-Identifier: MIT
// Creator: base64.tech
pragma solidity ^0.8.9;

import "./ERC721NES.sol";
import "hardhat/console.sol";

contract TestStakingController {
    address tokenContract;
    uint256 divisor;

    constructor(address _tokenContract, uint256 _divisor) {
        tokenContract = _tokenContract;
        divisor = _divisor;
    }
    
    function getStakingRewards(uint256 tokenId) public view returns(uint256) { 
        return ERC721NES(tokenContract).getCumulativeDurationStaked(tokenId) / divisor; // allows for toke accumulation at ~ 10 per hour
    }

    function stake(uint256 tokenId) public {
        require(ERC721NES(tokenContract).ownerOf(tokenId) == msg.sender, "You are not the owner of this token");
        
        ERC721NES(tokenContract).stake(tokenId, msg.sender);
    }

    function unstake(uint256 tokenId) public {
        require(ERC721NES(tokenContract).ownerOf(tokenId) == msg.sender, "You are not the owner of this token");
        
        ERC721NES(tokenContract).unstake(tokenId, msg.sender);
    }
}