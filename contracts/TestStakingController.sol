pragma solidity ^0.8.9;

import "./ERC721NCS.sol";

contract TestStakingController {
    address tokenContract;

    constructor(address _tokenContract) {
        tokenContract = _tokenContract;
    }
    
    function getStakingRewards(uint256 tokenId) public view returns(uint256) { 
        return ERC721NCS(tokenContract).getStakedCumulativeStakedBalance(tokenId) / 26; // allows for toke accumulation at ~ 10 per hour
    }

    function stake(uint256 tokenId) public {
        require(ERC721NCS(tokenContract).ownerOf(tokenId) == msg.sender);
        
        ERC721NCS(tokenContract).stake(tokenId, msg.sender);
    }

    function unstake(uint256 tokenId) public {
        require(ERC721NCS(tokenContract).ownerOf(tokenId) == msg.sender);
        
        ERC721NCS(tokenContract).unstake(tokenId, msg.sender);
    }
}