pragma solidity 0.4.24;

interface IIdentityStorage {

  /** Ownable */
  function owner() external view returns(address);
  function isOwner() external view returns(bool);
  function renounceOwnership() external;
  function transferOwnership(address newOwner) external;

  function setLatestVersion(address newVersion) external;
  
}