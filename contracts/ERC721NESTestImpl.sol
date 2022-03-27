// SPDX-License-Identifier: MIT
// Creator: base64.tech
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./ERC721NES.sol";

contract ERC721NESTestImpl is ERC721NES, Ownable {
    constructor() ERC721A("ERC721NESTESTIMPL", "ERC721NESTestImpl") {
    }

    function setStakingController(address _stakingController) public onlyOwner {
        _setStakingController(_stakingController);
    }

    function mint(uint256 _quanity) external {
        _mint(msg.sender,_quanity, '', false);
    }

}
