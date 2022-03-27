// SPDX-License-Identifier: MIT
// Creator: base64.tech
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./ERC721NES.sol";

interface StakingControllerI {
    function stake(uint256 tokenId) external;
}

contract ERC721NESTestImpl is ERC721NES, Ownable {
    StakingControllerI stakingControllerInterface;

    constructor() ERC721A("ERC721NESTESTIMPL", "ERC721NESTestImpl") {
    }

    function setStakingController(address _stakingController) public onlyOwner {
        _setStakingController(_stakingController);
        stakingControllerInterface = StakingControllerI(_stakingController);
    }

    function mint(uint256 _quanity) external {
        _mint(msg.sender,_quanity, '', false);
    }

    function mintAndStake(uint256 _quanity) external {
        uint256 startTokenId = _currentIndex;
        _mint(msg.sender,_quanity, '', false);
        for (uint256 i = startTokenId; i < _currentIndex; i++) { 
            stakingControllerInterface.stake(i);
        }
    }
}
