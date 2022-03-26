// SPDX-License-Identifier: MIT
// Creator: base64.tech

pragma solidity ^0.8.9;

import "./ERC721A.sol";
import "hardhat/console.sol";

/**
 *  @dev Extension of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard,
 *  that allows for Non Escrow Staking. By calling the stake function on a token, you disable
 *  the ability to transfer the token. By calling the unstake function on a token you re-enable
 *  the ability to transfer the token.
 *
 *  This implementation extends ERC721A, but can be modified to extend your own ERC721 implementation
 *  or the standard Open Zeppelin version.
 */
abstract contract ERC721NES is ERC721A {
    // This is an optional reference to an external contract allows
    // you to abstract away your staking interface to another contract.
    // if this variable is set, stake / unstake can only be called from  
    // the stakingController if it is not set stake / unstake can be called  
    // directly on the implementing contract.
    address stakingController;

    // Event published when a token is staked.
    event tokenStaked(uint256 tokenId);
    // Event published when a token is unstaked.
    event tokenUnstaked(uint256 tokenId);

    // Mapping of tokenId storing its staked status
    mapping(uint256 => bool) public tokenToIsStaked;

    /**
     *  @dev sets stakingController, scope of this method is internal, so this defaults
     *  to requiring setting the staking controller contact upon deployment or requires
     *  a public OnlyOwner helper method to be exposed in the implementing contract.
     */
    function _setStakingController(address _stakingController) internal {
        stakingController = _stakingController;
    }

    /**
     *  @dev returns whether a token is currently staked
     */
    function isStaked(uint256 tokenId) public view returns (bool) {
        return tokenToIsStaked[tokenId];
    }

    /**
     *  @dev marks a token as staked, can only be performed by token holder or
     *  delegated staking controller contract. By calling this function
     *  you disable the ability to transfer the token.
     */
    function stake(uint256 tokenId, address originator) public {
        require(
            (stakingController == address(0) &&
                ownerOf(tokenId) == msg.sender) ||
                (ownerOf(tokenId) == originator &&
                    msg.sender == stakingController),
            "Originator is not the owner of this token"
        );
        require(!isStaked(tokenId), "token is already staked");
        tokenToIsStaked[tokenId] = true;
    }

    /**
     *  @dev marks a token as unstaked, can only be performed by token holder or
     *  delegated staking controller contract. By calling this function
     *  you re-enable the ability to transfer the token.
     */
    function unstake(uint256 tokenId, address originator) public {
        require(
            (stakingController == address(0) &&
                ownerOf(tokenId) == msg.sender) ||
                (ownerOf(tokenId) == originator &&
                    msg.sender == stakingController),
            "Originator is not the owner of this token"
        );
        require(isStaked(tokenId), "token isn't staked");

        tokenToIsStaked[tokenId] = false;
    }

    /**
     *  @dev perform safe mint and stake
     */
    function _safemintAndStake(address to, uint256 quantity) internal {
        uint256 startTokenId = _currentIndex;

        for (uint256 i = 0; i < quantity; i++) {
            startTokenId++;
            tokenToIsStaked[startTokenId] = true;
        }
        _safeMint(to, quantity, "");
    }

    /**
     *  @dev perform mint and stake
     */
    function _mintAndStake(address to, uint256 quantity) internal {
        uint256 startTokenId = _currentIndex;

        for (uint256 i = 0; i < quantity; i++) {
            startTokenId++;
            tokenToIsStaked[startTokenId] = true;
        }
        _mint(to, quantity, "", false);
    }

    /**
     * @dev overrides transferFrom to prevent transfer if token is staked
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public override {
        require(
            isStaked(tokenId) == false,
            "You can not transfer a staked token"
        );
        super.transferFrom(from, to, tokenId);
    }

    /**
     * @dev overrides safeTransferFrom to prevent transfer if token is staked
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public override {
        require(
            isStaked(tokenId) == false,
            "You can not transfer a staked token"
        );
        super.safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev overrides safeTransferFrom to prevent transfer if token is staked
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public override {
        require(
            isStaked(tokenId) == false,
            "You can not transfer a staked token"
        );
        super.safeTransferFrom(from, to, tokenId, _data);
    }
}
