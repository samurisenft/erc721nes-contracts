// SPDX-License-Identifier: MIT
// Creator: base64.tech
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./ERC721NES.sol";

/**
 *  @dev This is a sample implementation of a ERC721NES that utilizes a Staking Controller,
 *  ERC721NESTestStakingController, allowing for segregation of the minting logic from the 
 *  staking logic.
 */
contract ERC721NESTestImpl is ERC721NES, Ownable {
    /**
     *  @dev constructor 
     */
    constructor() ERC721A("ERC721NESTESTIMPL", "ERC721NESTestImpl") {
    }

    /**
     *  @dev sets the Staking Controller contract.
     */
    function setStakingController(address _stakingController) public onlyOwner {
        _setStakingController(_stakingController);
    }
   
    /**
     *  @dev Mints token.
     */
    function mint(uint256 _quanity) external {
        _mint(msg.sender,_quanity, '', false);
    }

}
