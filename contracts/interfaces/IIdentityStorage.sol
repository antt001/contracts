// This code has not been professionally audited, therefore I cannot make any promises about
// safety or correctness. Use at own risk.

pragma solidity 0.4.24;

interface IIdentityStorage {

  /** Ownable */
  function owner() external view returns(address);
  function isOwner() external view returns(bool);
  function renounceOwnership() external;
  function transferOwnership(address newOwner) external;

  function setLatestVersion(address newVersion) external;

  function createIdentity(address id, address wallet) external;

  function identityHasMissionType(address id, address missionContract) external view returns(bool);
  function identityAddMissionType(address id, address missionContract) external;
  function getIdentityWallet(address id) external view returns(address);
}