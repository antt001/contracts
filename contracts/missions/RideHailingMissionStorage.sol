pragma solidity 0.4.24;

import 'openzeppelin-solidity/contracts/ownership/Ownable.sol';
import '../interfaces/IMissionStorage.sol';

library MissionStruct {
  struct RideHailingMission {
    address seller;
    address buyer;
    uint256 deposit;
    uint256 actualPrice;
    uint256 balance;
    bool isSigned;
    mapping (uint8 => bool) resolvers;
  }    
}

contract RideHailingMissionStorage is IMissionStorage, Ownable {

  address _latestVersion;
  mapping (bytes32 => MissionStruct.RideHailingMission) private missions;
  
  modifier onlyLatestVersion() {
    require(
      msg.sender == _latestVersion,
      'Only latest version access is allowed'
    );
    _;
  }

  function setLatestVersion(address newVersion) public onlyOwner {
    _latestVersion = newVersion;
  }

  function createMission(bytes32 missionId, address sellerId, address buyerId, uint256 tokenAmount) external onlyLatestVersion {
    // Create mission
    missions[missionId] = MissionStruct.RideHailingMission({
      seller: sellerId,
      buyer: buyerId,
      deposit: tokenAmount,
      actualPrice: 0,
      balance: tokenAmount,
      isSigned: false
    });
  }

  function getMissionBuyer(bytes32 missionId) public returns(address buyer) {
    return missions[missionId].buyer;
  }

  function getMissionSeller(bytes32 missionId) external returns(address seller) {
    return missions[missionId].seller;
  }

  function setMissionBalance(bytes32 missionId, uint256 balance)  public onlyLatestVersion {
    missions[missionId].balance = balance;
  }

  function getMissionBalance(bytes32 missionId) public returns(uint256 balance) {
    return missions[missionId].balance;
  }

  function setMissionActualPrice(bytes32 missionId, uint256 actualPrice)  public onlyLatestVersion {
    missions[missionId].actualPrice = actualPrice;
  }

  function getMissionActualPrice(bytes32 missionId) public returns(uint256 actualPrice) {
    return missions[missionId].actualPrice;
  }

  function getMissionDeposit(bytes32 missionId) public returns(uint256 deposit) {
    return missions[missionId].deposit;
  }
  
  function setMissionIsSigned(bytes32 missionId, bool isSigned) public onlyLatestVersion {
    missions[missionId].isSigned = isSigned;
  }

  function getMissionIsSigned(bytes32 missionId) public returns(bool isSigned){
    return missions[missionId].isSigned;
  }
}