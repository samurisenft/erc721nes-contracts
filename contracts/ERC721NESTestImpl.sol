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

    function mint() external {
        _mint(msg.sender,1, '', false);
    }

    function mintAndStake() external {
        _mintAndStake(msg.sender,1);
    }

    //metadata URI
    string private _baseTokenURI;

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }

    function setBaseURI(string calldata baseURI) external onlyOwner {
        _baseTokenURI = baseURI;
    }

}
