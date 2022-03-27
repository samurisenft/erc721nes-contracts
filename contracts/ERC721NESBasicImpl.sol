// SPDX-License-Identifier: MIT
// Creator: base64.tech
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./ERC721NES.sol";

/**
 *  @dev This is a sample implementation of a ERC721NES that does not utilize a separate
 *  Staking Controller contract and include both minting and staking logic inline.
 */
contract ERC721NESBasicImpl is ERC721NES, Ownable {
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
    constructor(uint256 _multipler)
        ERC721A("ERC721NESBasicImpl", "ERC721NESBasicImpl")
    {
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
        return getCumulativeDurationStaked(tokenId) * multiplier;
    }

    /**
     *  @dev Stakes a token and records the start block number or time stamp.
     */
    function stake(uint256 tokenId) public {
        require(
            ownerOf(tokenId) == msg.sender,
            "You are not the owner of this token"
        );

        tokenToWhenStaked[tokenId] = block.number;
        _stake(tokenId);
    }

    /**
     *  @dev Unstakes a token and records the start block number or time stamp.
     */
    function unstake(uint256 tokenId) public {
        require(
            ownerOf(tokenId) == msg.sender,
            "You are not the owner of this token"
        );

        tokenToTotalDurationStaked[tokenId] += getCurrentAdditionalBalance(
            tokenId
        );
        _unstake(tokenId);
    }

    /**
     *  @dev Mints token.
     */
    function mint(uint256 _quanity) external {
        _mint(msg.sender, _quanity, "", false);
    }
}