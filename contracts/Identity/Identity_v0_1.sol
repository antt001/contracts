pragma solidity 0.4.24;

import '../interfaces/IDAVToken.sol';
import '../interfaces/IIdentityStorage.sol';
import '../interfaces/IIdentity.sol';


/**
 * @title Identity
 */
contract Identity_v0_1 is IIdentity {

  IDAVToken private _token;
  IIdentityStorage private _identityStorage;

  // Prefix to added to messages signed by web3
  bytes28 private constant ETH_SIGNED_MESSAGE_PREFIX = '\x19Ethereum Signed Message:\n32';
  bytes25 private constant DAV_REGISTRATION_REQUEST = 'DAV Identity Registration';
  bytes private constant a = '0x90f8bf6a479f320ead074411a4b0e7944ea8c9c1';

  modifier onlyUnregisteredIds(address _id) {
    require(
      isRegistered(_id) == false,
      'Only unregistered ids are allowed'
    );
    _;
  }
  /**
   * @dev Constructor
   *
   * @param davTokenContract address of the DAVToken contract
   */
  constructor(IDAVToken davTokenContract, IIdentityStorage identityStorage ) public {
    _token = davTokenContract;
    _identityStorage = identityStorage;
  }

  function register(address id, uint8 v, bytes32 r, bytes32 s) public onlyUnregisteredIds(id) {
    // Generate message hash
    bytes32 prefixedHash = keccak256(abi.encodePacked(ETH_SIGNED_MESSAGE_PREFIX, keccak256(abi.encodePacked(DAV_REGISTRATION_REQUEST))));
    // Verify message signature
    require(
      ecrecover(prefixedHash, v, r, s) == id,
      'Signature is not valid'
    );

    // Register in identities mapping
    _identityStorage.createIdentity(id, msg.sender);
  }

  function registerSimple() public onlyUnregisteredIds(msg.sender) {
    // Register in identities mapping
    _identityStorage.createIdentity(msg.sender, msg.sender);
  }

  function getBalance(address id) public view returns (uint256 balance) {
    return _token.balanceOf(_identityStorage.getIdentityWallet(id));
  }

  function verifyOwnership(address id, address wallet) public view returns (bool verified) {
    return _identityStorage.getIdentityWallet(id) == wallet;
  }

  // Check identity registration status
  function isRegistered(address id) public view returns (bool) {
    return _identityStorage.getIdentityWallet(id) != 0x0;
  }

  // Get identity wallet
  function getIdentityWallet(address id) public view returns (address) {
    return _identityStorage.getIdentityWallet(id);
  }

  function identityHasSenderMissionType(address id) public view returns(bool) {
    return _identityStorage.identityHasMissionType(id, msg.sender);
  }

  function identityAddMissionType(address id, uint8 v, bytes32 r, bytes32 s) external {
    require(
      identityHasSenderMissionType(id) == false,
      'Only unregistered mission types are allowed'
    );
    // Generate message hash
    string memory sender = toAsciiString(bytes32(msg.sender));
    bytes32 senderHash = keccak256(abi.encodePacked('0x', sender));
    bytes32 prefixedHash = keccak256(
      abi.encodePacked(ETH_SIGNED_MESSAGE_PREFIX, senderHash)
    );

    // Verify message signature
    require(
      ecrecover(prefixedHash, v, r, s) == id,
      'Signature is not valid'
    );

    _identityStorage.identityAddMissionType(id, msg.sender);
  }

  function toAsciiString(bytes32 data) internal pure returns (string) {
    bytes memory s = new bytes(40);
    for (uint i = 0; i < 20; i++) {
      byte b = byte(uint8(uint(data) / (2**(8*(19 - i)))));
      byte hi = byte(uint8(b) / 16);
      byte lo = byte(uint8(b) - 16 * uint8(hi));
      s[2*i] = char(hi);
      s[2*i+1] = char(lo);            
    }
    return string(s);
  }

  function char(byte b) internal pure returns (byte c) {
    if (b < 10) return byte(uint8(b) + 0x30);
    else return byte(uint8(b) + 0x57);
  }
}
