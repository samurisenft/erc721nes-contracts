// SPDX-License-Identifier: MIT
// Creator: base64.tech

pragma solidity ^0.8.9;

import './ERC721A.sol';

abstract contract ERC721ANonCustodialStaking is ERC721A {

    // for each token, stores the latest block number
    mapping(uint256 => uint256) public tokenToBlockNumberStaked;
    // for each token, stores the total amount of time staked in block time
    mapping(uint256 => uint256) public tokenToBlockNumberStakedCumulative;
    
    // this is a multipler to convert number of blocks to token count
    // defaulted to 1
    uint256 private multiplier = 1;

    // this is a divisor to convert number of blocks to token count
    // defaulted to 1
    uint256 private divisor = 1;

    function setDivisor(uint256 _divisor) public {
        divisor = _divisor;
    }

    function getCurrentAdditionalBalance(uint256 tokenId) public view returns (uint256) {
        return block.number - tokenToBlockNumberStakedCumulative[tokenId];
    }

    // gets the balance of staking rewards 
    function getStakedCumulativeBalance(uint256 tokenId) public view returns (uint256){
        return ((tokenToBlockNumberStakedCumulative[tokenId] + getCurrentAdditionalBalance(tokenId))) / divisor;
    }

    function isStaked(uint256 tokenId) public view returns (bool) {
        return tokenToBlockNumberStaked[tokenId] != 0;
    }

    function stake(uint256 tokenId) public {
        require(ownerOf(tokenId) == msg.sender, "You are not the owner of this token");
        require(!isStaked(tokenId), "token is already staked");
        
        tokenToBlockNumberStaked[tokenId] = block.number;
    }

    function unstake(uint256 tokenId) public {
        require(ownerOf(tokenId) == msg.sender, "You are not the owner of this token");
        require(isStaked(tokenId), "token isn't staked");
        
        tokenToBlockNumberStakedCumulative[tokenId] += block.number - tokenToBlockNumberStakedCumulative[tokenId];
        tokenToBlockNumberStaked[tokenId] = 0; // setting to 0 indicates a token is unstaked
    }

    function _safemintAndStake(address to, uint256 quantity) internal {
        uint256 startTokenId = _currentIndex;
 
        for(uint256 i = 0; i < quantity; i++){
            startTokenId++;
            tokenToBlockNumberStaked[startTokenId] = block.number;
        }
        _safeMint(to, quantity, '');
    }

    function _mintAndStake(address to, uint256 quantity) internal {
        uint256 startTokenId = _currentIndex;
 
        for(uint256 i = 0; i < quantity; i++){
            startTokenId++;
            tokenToBlockNumberStaked[startTokenId] = block.number;
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
