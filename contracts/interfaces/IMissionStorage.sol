pragma solidity 0.4.24;

interface IMissionStorage {

  /** Ownable */
  function owner() external view returns(address);
  function isOwner() external view returns(bool);
  function renounceOwnership() external;
  function transferOwnership(address newOwner) external;

  function setLatestVersion(address newVersion) external;

  function createMission(bytes32 missionId, address sellerId, address buyerId, uint256 tokenAmount) external;
  function getMissionSeller(bytes32 missionId) external returns(address seller);
  function getMissionBuyer(bytes32 missionId) external returns(address buyer);
  function setMissionBalance(bytes32 missionId, uint256 balance)  external;
  function getMissionBalance(bytes32 missionId) external returns(uint256 balance);
  function getMissionCost(bytes32 missionId) external returns(uint256 cost);
  function setMissionIsSigned(bytes32 missionId, bool isSigned)  external;
  function getMissionIsSigned(bytes32 missionId) external returns(bool isSigned);
}