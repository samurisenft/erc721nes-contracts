// SPDX-License-Identifier: MIT
// Creator: base64.tech

pragma solidity ^0.8.9;

import './ERC721A.sol';

abstract contract ERC721ANonCustodialStaking is ERC721A {

    mapping(uint256 => uint256) public tokenToBlockTimeStampStaked;
    mapping(uint256 => uint256) public tokenToBlockTimeStakedCumulative;
    
    // this is a multipler to convert time staked in hours to token count
    // defaulted to 1
    uint256 private multiplier = 1;
    uint256 private blockStartTime;

    function setMultiplier(uint256 _multiplier) public {
        multiplier = _multiplier;
    }

    function getCurrentAdditionalBalance(uint256 tokenId) public view returns (uint256) {
        return block.timestamp - tokenToBlockTimeStakedCumulative[tokenId];
    }

    function getStakedCumulativeBalance(uint256 tokenId) public view returns (uint256){
        return ((tokenToBlockTimeStakedCumulative[tokenId] + getCurrentAdditionalBalance(tokenId)) / 60 / 60) * multiplier;
    }

    function isStaked(uint256 tokenId) public view returns (bool) {
        return tokenToBlockTimeStampStaked[tokenId] != 0;
    }

    function stake(uint256 tokenId) public {
        require(ownerOf(tokenId) == msg.sender, "You are not the owner of this token");
        require(!isStaked(tokenId), "token is already staked");
        
        tokenToBlockTimeStampStaked[tokenId] = block.timestamp;
    }

    function unstake(uint256 tokenId) public {
        require(ownerOf(tokenId) == msg.sender, "You are not the owner of this token");
        require(isStaked(tokenId), "token isn't staked");
        
        tokenToBlockTimeStakedCumulative[tokenId] += block.timestamp - tokenToBlockTimeStakedCumulative[tokenId];
        tokenToBlockTimeStampStaked[tokenId] = 0; // setting to 0 indicates a token is unstaked
    }

    function _safemintAndStake(address to, uint256 quantity) internal {
        uint256 startTokenId = _currentIndex;
 
        for(uint256 i = 0; i < quantity; i++){
            startTokenId++;
            tokenToBlockTimeStampStaked[startTokenId] = block.timestamp;
        }
        _safeMint(to, quantity, '');
    }

    function _mintAndStake(address to, uint256 quantity) internal {
        uint256 startTokenId = _currentIndex;
 
        for(uint256 i = 0; i < quantity; i++){
            startTokenId++;
            tokenToBlockTimeStampStaked[startTokenId] = block.timestamp;
        }
        _mint(to, quantity, '', false);
    }


    /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public override {
        require(isStaked(tokenId) == false, 'You can not transfer a staked token');
        super.transferFrom(from, to, tokenId);
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public override {
        require(isStaked(tokenId) == false, 'You can not transfer a staked token');
        safeTransferFrom(from, to, tokenId, '');
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public  override {
        require(isStaked(tokenId) == false, 'You can not transfer a staked token');
       super.safeTransferFrom(from, to, tokenId, _data);
    }

}
