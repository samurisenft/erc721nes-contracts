pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "./ERC721ANonCustodialStaking.sol";

contract Test721 is ERC721ANonCustodialStaking, Ownable, Pausable, ReentrancyGuard {
    using ECDSA for bytes32;
    using Strings for uint256;
    
    uint256 public constant TOTAL_MAX_SUPPLY = 10000;
    uint256 public constant TOKEN_PRICE = .047 ether;
    uint256 public mintIndex=0;
    address public signatureVerifier;
    mapping(address => uint256) public addressToAmountWLMintedSoFar; 

    constructor() ERC721A("Test721", "TEST721") {
        _pause();
        setMultiplier(20); // every hour staked you earn 20 tokens
    }

    modifier callerIsUser() {
        require(tx.origin == msg.sender, "The caller is another contract");
        _;
    }

    function hashMessage(address sender, uint256 nonce) public pure returns(bytes32) {
        bytes32 hash = keccak256(abi.encodePacked(
            "\x19Ethereum Signed Message:\n32",
            keccak256(abi.encodePacked(sender, nonce))));
        return hash;
    }

    function allowListMint(bytes memory _signature, uint256 _nonce) whenNotPaused payable callerIsUser external {
        require(msg.value >= TOKEN_PRICE, "Need to send more ETH.");
        require(numberMinted(msg.sender) + 1 < 2, "1 allow list mint per wallet allocation exceeded");
        require(mintIndex < TOTAL_MAX_SUPPLY, "Purchase would exceed max supply");
        bytes32 messageHash = hashMessage(msg.sender, _nonce);
        require(messageHash.recover(_signature) == signatureVerifier, "Unrecognizable Hash");
        
        _mint(msg.sender,1, '', false);
        unchecked {
            mintIndex++;
        }
        
    }

    function allowListMintAndStake(bytes memory _signature, uint256 _nonce) whenNotPaused payable callerIsUser external {
        require(msg.value >= TOKEN_PRICE, "Need to send more ETH.");
        require(numberMinted(msg.sender) + 1 < 2, "1 allow list mint per wallet allocation exceeded");
        require(mintIndex + 1  < TOTAL_MAX_SUPPLY + 1, "Purchase would exceed max supply");
        bytes32 messageHash = hashMessage(msg.sender, _nonce);
        require(messageHash.recover(_signature) == signatureVerifier, "Unrecognizable Hash");

        _mintAndStake(msg.sender,1);
        unchecked {
            mintIndex++;
        }
    }

    

    // // metadata URI
    string private _baseTokenURI;

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }

    function setBaseURI(string calldata baseURI) external onlyOwner {
        _baseTokenURI = baseURI;
    }

    function withdrawMoney() external onlyOwner nonReentrant {
        (bool success, ) = msg.sender.call{value: address(this).balance}("");
        require(success, "Transfer failed.");
    }

    function numberMinted(address owner) public view returns (uint256) {
        return _numberMinted(owner);
    }

 
    function getOwnershipData(uint256 tokenId)
        external
        view
        returns (TokenOwnership memory)
    {
        return ownershipOf(tokenId);
    }

    function setSignatureVerifier(address _signatureVerifier) external onlyOwner {
        signatureVerifier = _signatureVerifier;
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }
    

}
