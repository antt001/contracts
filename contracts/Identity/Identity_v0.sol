pragma solidity 0.4.24;

import '../interfaces/IDAVToken.sol';
import '../interfaces/IIdentityStorage.sol';


/**
 * @title Identity
 */
contract Identity_v0 {

  IDAVToken private token;
  IIdentityStorage private identityStorage;

  // Prefix to added to messages signed by web3
  bytes28 private constant ETH_SIGNED_MESSAGE_PREFIX = '\x19Ethereum Signed Message:\n32';
  bytes25 private constant DAV_REGISTRATION_REQUEST = 'DAV Identity Registration';

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
   * @param _davTokenContract address of the DAVToken contract
   */
  constructor(IDAVToken _davTokenContract, IIdentityStorage _storage ) public {
    token = _davTokenContract;
    identityStorage = _storage;
  }

  function register(address _id, uint8 _v, bytes32 _r, bytes32 _s) public onlyUnregisteredIds(_id) {
    // Generate message hash
    bytes32 prefixedHash = keccak256(abi.encodePacked(ETH_SIGNED_MESSAGE_PREFIX, keccak256(abi.encodePacked(DAV_REGISTRATION_REQUEST))));
    // Verify message signature
    require(
      ecrecover(prefixedHash, _v, _r, _s) == _id,
      'Signature is not valid'
    );

    // Register in identities mapping
    identityStorage.setAddress(keccak256(abi.encodePacked('identities_wallets', _id)), msg.sender);
  }

  function registerSimple() public onlyUnregisteredIds(msg.sender) {
    // Register in identities mapping
    identityStorage.setAddress(keccak256(abi.encodePacked('identities_wallets', msg.sender)), msg.sender);
  }

  function getBalance(address _id) public view returns (uint256 balance) {
    return token.balanceOf(identityStorage.getAddress(keccak256(abi.encodePacked('identities_wallets', _id))));
  }

  function verifyOwnership(address _id, address _wallet) public view returns (bool verified) {
    return identityStorage.getAddress(keccak256(abi.encodePacked('identities_wallets', _id))) == _wallet;
  }

  // Check identity registration status
  function isRegistered(address _id) public view returns (bool) {
    return identityStorage.getAddress(keccak256(abi.encodePacked('identities_wallets', _id))) != 0x0;
  }

  // Get identity wallet
  function getIdentityWallet(address _id) public view returns (address) {
    return identityStorage.getAddress(keccak256(abi.encodePacked('identities_wallets', _id)));
  }
}
