pragma solidity 0.4.24;

interface IIdentity {
  function register(address id, uint8 v, bytes32 r, bytes32 s) external;
  function registerSimple() external;
  function getBalance(address id) external view returns (uint256 balance);
  function verifyOwnership(address id, address wallet) external view returns (bool verified);
  function isRegistered(address id) external view returns (bool);
  function getIdentityWallet(address id) external view returns (address);
  function identityHasSenderMissionType(address id) external view returns(bool);
  function identityAddMissionType(address id, uint8 v, bytes32 r, bytes32 s) external;
}