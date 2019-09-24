pragma solidity ^0.5.0;

import "./token/ERC20/ERC20.sol";
import "./cryptography/ECDSA.sol";
import "./math/SafeMath.sol";
import "./access/ownership/owned.sol";

contract ERC20Certificate is ERC20, owned  {

    using ECDSA for bytes32;
    using SafeMath for uint256;

    /// ###########################
    /// ##    Certificates       ##
    /// ###########################
    mapping (bytes32 => certificateType) public certificateTypes;

    struct certificateType {
        uint256 amount;
        string metadata;
        mapping (address => bool) delegates;
        mapping (address => bool) claimed;
    }

    modifier allowRedeem(bytes32 _certificateID, bytes memory _signature) {
        bytes32 hash = keccak256(abi.encodePacked(_certificateID, address(this), msg.sender));
        require(_isDelegateSigned(hash, _signature, _certificateID), "Not Delegate Signed");
        require(!certificateTypes[_certificateID].claimed[msg.sender], "Cert already claimed");
        _;
    }

    function createCertificateType(uint256 _amount, address[] memory _delegates, string memory _metadata) public onlyOwner {
        bytes32 certID = _getCertificateID(_amount, _delegates, _metadata);
        certificateTypes[certID].amount = _amount;
        certificateTypes[certID].metadata = _metadata;

        for (uint8 i = 0; i < _delegates.length; i++) {
            certificateTypes[certID].delegates[_delegates[i]] = true;
        }
        emit CertificateTypeCreated(certID, _amount, _delegates);
    }

    function redeemCertificate(bytes memory anchorSignature, bytes32 certificateID)
        public allowRedeem(certificateID, anchorSignature)
        returns (bool)
    {
        certificateTypes[certificateID].claimed[msg.sender] = true;
        uint256 amount = certificateTypes[certificateID].amount;
        _mint(msg.sender, amount);
        emit CertificateRedeemed(msg.sender, amount, certificateID);
        return true;
    }

    // View Functions
    function getCertificateData(bytes32 _certificateID) public view returns (string memory) {
        return certificateTypes[_certificateID].metadata;
    }

    function getCertificateID(uint _amount, address[] memory _delegates, string memory _metadata) public view returns (bytes32) {
        return _getCertificateID(_amount,_delegates, _metadata);
    }

    function isDelegateSigned(bytes32 _msgHash, bytes memory _signature, bytes32 _certificateID) public view returns (bool) {
        return _isDelegateSigned(_msgHash, _signature, _certificateID);
    }

    function isCertificateDelegate(bytes32 _certificateID, address _delegate) public view returns (bool) {
        return certificateTypes[_certificateID].delegates[_delegate];
    }

    function isCertificateClaimed(bytes32 _certificateID, address _recipient) public view returns (bool) {
        return certificateTypes[_certificateID].claimed[_recipient];
    }

    // Internal Functions
    function _getCertificateID(uint _amount, address[] memory _delegates, string memory _metadata) internal view returns (bytes32) {
        return keccak256(abi.encodePacked(_amount,address(this),_delegates, _metadata));
    }
    function _isDelegateSigned(bytes32 msgHash, bytes memory signature, bytes32 _certificateID) internal view returns (bool) {
        return certificateTypes[_certificateID].delegates[msgHash.toEthSignedMessageHash().recover(signature)];
    }

    event CertificateTypeCreated(bytes32 indexed _id, uint256 _amount, address[] _delegates);
    event CertificateRedeemed(address indexed _from, uint256 _value, bytes32 _certificateID);

}