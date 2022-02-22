// SPDX-License-Identifier: MIT
// Creator: base64.tech

pragma solidity ^0.8.9;

import './ERC721A.sol';
import "hardhat/console.sol";

abstract contract ERC721NCS is ERC721A {

    address stakingController;
    // for each token, stores the current block.number or block.timestamp
    // if token is mapped to 0, it is currently unstaked
    mapping(uint256 => uint256) public tokenToWhenStaked;
    // for each token, stores the total duration staked 
    // measured by block.number or block.timestamp 
    mapping(uint256 => uint256) public tokenToTotalDurationStaked;
    
    // determines whether token balance is calculated based off of 
    // block.number or block.timestamp, defaults to block.number
    bool private blockNumberBased = true;

    function setStakingController(address _stakingController) public {
        stakingController = _stakingController;
    }

    function setBlockNumberBased(bool _blockNumberBased) public {
        blockNumberBased = _blockNumberBased;
    }

    function getBlockNumberOrTimeStamp() private view returns (uint256) {
        return (blockNumberBased == true ? block.number: block.timestamp);
    }

    function getCurrentAdditionalBalance(uint256 tokenId) public view returns (uint256) {
        return  getBlockNumberOrTimeStamp() - tokenToWhenStaked[tokenId];
    }

    // returns the total duration staked 
    function getStakedCumulativeStakedBalance(uint256 tokenId) public view returns (uint256){
        return tokenToTotalDurationStaked[tokenId] + getCurrentAdditionalBalance(tokenId);
    }

    function isStaked(uint256 tokenId) public view returns (bool) {
        return tokenToWhenStaked[tokenId] != 0;
    }

    function stake(uint256 tokenId, address originator) public {
        require( ownerOf(tokenId) == msg.sender || (ownerOf(tokenId) == originator && msg.sender == stakingController), "Originator is not the owner of this token");
        require(!isStaked(tokenId), "token is already staked");
        tokenToWhenStaked[tokenId] = getBlockNumberOrTimeStamp();
    }

    function unstake(uint256 tokenId, address originator) public {
        require( ownerOf(tokenId) == msg.sender || (ownerOf(tokenId) == originator && msg.sender == stakingController), "Originator is not the owner of this token");
        require(isStaked(tokenId), "token isn't staked");
        
        tokenToTotalDurationStaked[tokenId] += getCurrentAdditionalBalance(tokenId);
        tokenToWhenStaked[tokenId] = 0; // setting to 0 indicates a token is unstaked
    }

    function _safemintAndStake(address to, uint256 quantity) internal {
        uint256 startTokenId = _currentIndex;
 
        for(uint256 i = 0; i < quantity; i++){
            startTokenId++;
            tokenToWhenStaked[startTokenId] = getBlockNumberOrTimeStamp();
        }
        _safeMint(to, quantity, '');
    }

    function _mintAndStake(address to, uint256 quantity) internal {
        uint256 startTokenId = _currentIndex;
 
        for(uint256 i = 0; i < quantity; i++){
            startTokenId++;
            tokenToWhenStaked[startTokenId] = getBlockNumberOrTimeStamp();
        }
        _mint(to, quantity, '', false);
    }

    /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(address from, address to, uint256 tokenId) public override {
        require(isStaked(tokenId) == false, 'You can not transfer a staked token');
        super.transferFrom(from, to, tokenId);
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) public override {
        require(isStaked(tokenId) == false, 'You can not transfer a staked token');
        super.safeTransferFrom(from, to, tokenId, '');
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public  override {
        require(isStaked(tokenId) == false, 'You can not transfer a staked token');
        super.safeTransferFrom(from, to, tokenId, _data);
    }

}
