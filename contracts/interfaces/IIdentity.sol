pragma solidity 0.4.24;

interface IIdentity {
  function register(address _id, uint8 _v, bytes32 _r, bytes32 _s) external;
  function registerSimple() external;
  function getBalance(address _id) external view returns (uint256 balance);
  function verifyOwnership(address _id, address _wallet) external view returns (bool verified);
  function isRegistered(address _id) external view returns (bool);
  function getIdentityWallet(address _id) external view returns (address);
}