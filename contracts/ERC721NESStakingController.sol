// SPDX-License-Identifier: MIT
// Creator: base64.tech
pragma solidity ^0.8.13;

import "./ERC721NES.sol";

/**
 *  @dev This is a sample implementation of a staking controller use in conjunction with
 *  an contract that implements ERC721NES.
 *
 *  This implementation captures the total duration staked for a given token either by
 *  block.timestamp or by block.number and provides a divisor to convert this value
 *  to a balance.
 */
contract ERC721NESStakingController {
    // Address of the ERC721 token contract
    address tokenContract;
    // block number multiplier to determine the balance to accrue
    // during the duration staked. Defaults to 1.
    uint256 multiplier = 1;

    // For each token, this map stores the current block.number
    // if token is mapped to 0, it is currently unstaked.
    mapping(uint256 => uint256) public tokenToWhenStaked;

    // For each token, this map stores the total duration staked
    // measured by block.number
    mapping(uint256 => uint256) public tokenToTotalDurationStaked;

    /**
     *  @dev constructor
     */
    constructor(address _tokenContract, uint256 _multipler) {
        tokenContract = _tokenContract;
        multiplier = _multipler;
    }

    /**
     *  @dev returns the additional balance between when token was staked until now
     */
    function getCurrentAdditionalBalance(uint256 tokenId)
        public
        view
        returns (uint256)
    {
        if (tokenToWhenStaked[tokenId] > 0) {
            return block.number - tokenToWhenStaked[tokenId];
        } else {
            return 0;
        }
    }

    /**
     *  @dev returns total duration the token has been staked.
     */
    function getCumulativeDurationStaked(uint256 tokenId)
        public
        view
        returns (uint256)
    {
        return
            tokenToTotalDurationStaked[tokenId] +
            getCurrentAdditionalBalance(tokenId);
    }

    /**
     *  @dev Returns the amount of tokens rewarded up until this point.
     */
    function getStakingRewards(uint256 tokenId) public view returns (uint256) {
        return getCumulativeDurationStaked(tokenId) * multiplier; // allows for toke accumulation at ~ 10 per hour
    }

    /**
     *  @dev Stakes a token and records the start block number or time stamp.
     */
    function stake(uint256 tokenId) public {
        require(
            ERC721NES(tokenContract).ownerOf(tokenId) == msg.sender,
            "You are not the owner of this token"
        );

        tokenToWhenStaked[tokenId] = block.number;
        ERC721NES(tokenContract).stakeFromController(tokenId, msg.sender);
    }

    /**
     *  @dev Unstakes a token and records the start block number or time stamp.
     */
    function unstake(uint256 tokenId) public {
        require(
            ERC721NES(tokenContract).ownerOf(tokenId) == msg.sender,
            "You are not the owner of this token"
        );

        tokenToTotalDurationStaked[tokenId] += getCurrentAdditionalBalance(
            tokenId
        );
        tokenToWhenStaked[tokenId] = 0;
        ERC721NES(tokenContract).unstakeFromController(tokenId, msg.sender);
    }
}