pragma solidity 0.4.24;

import '../interfaces/IIdentity.sol';
import '../interfaces/IDAVToken.sol';
import '../interfaces/IMissionStorage.sol';

/**
 * @title BasicMission
 * @dev The most basic contract for conducting Missions.
 *
 * This contract represents the very basic interface of a mission contract.
 * In the real world, there is very little reason to use this and not one of the
 * contracts that extend it. Consider this an interface, more than an implementation.
 */
contract RideHailingMission {

  IMissionStorage private _missionStorage;
  uint256 private nonce;

  event Create(
    bytes32 id,
    address sellerId,
    address buyerId
  );

  event Signed(
    bytes32 id
  );

  IDAVToken private _token;
  IIdentity private _identity;

  /**
   * @dev Constructor
   *
   * @param identityContract address of the Identity contract
   * @param davTokenContract address of the DAVToken contract
   */
  constructor(IIdentity identityContract, IDAVToken davTokenContract, IMissionStorage missionStorage) public {
    _identity = identityContract;
    _token = davTokenContract;
    _missionStorage = missionStorage;
  }

  /**
   * @notice Create a new mission
   * @param sellerId The DAV Identity of the person providing the service
   * @param buyerId The DAV Identity of the person ordering the service
   * @param tokenAmount The amount of tokens to be burned when mission is completed
   */
  function create(bytes32 missionId, address sellerId, address buyerId, uint256 tokenAmount) public payable {
    // Verify that message sender controls the buyer's wallet
    require(
      _identity.verifyOwnership(buyerId, msg.sender),
      'Transaction must be sent from buyer\'s identity wallet'
    );

    // Verify buyer's balance is sufficient
    require(
      _identity.getBalance(buyerId) >= tokenAmount,
      'Insufficient token balance'
    );

    // Make sure id isn't registered already
    require(
      _missionStorage.getMissionBuyer(missionId) == 0x0,
      'Mission id already exist'
    );

    // Transfer tokens to the mission contract
    _token.transferFrom(msg.sender, this, tokenAmount);

    // Create mission
    _missionStorage.createMission(missionId, sellerId, buyerId, tokenAmount);

    // Event
    emit Create(missionId, sellerId, buyerId);
  }

  /**
  * @notice mark fulfilled a mission
  * @param missionId The id of the mission
  */
  function fulfilled(bytes32 missionId) public {
    // Verify that message sender controls the seller's wallet
    require(
      _identity.verifyOwnership(_missionStorage.getMissionBuyer(missionId), msg.sender),
      'Transaction must be sent from buyer\'s identity wallet'
    );
    
    require(
      _missionStorage.getMissionIsSigned(missionId) == false,
      'Mission is already fulfilled'
    );

    require(
      _missionStorage.getMissionBalance(missionId) == _missionStorage.getMissionCost(missionId),
      'Mission balance is not equal to mission cost'
    );
    
    require(
      // address(this).balance >= _missionStorage.getMissionCost(missionId),
      _token.balanceOf(this) >= _missionStorage.getMissionCost(missionId),
      'Insufficient token balance in contract'
    );
    
    // designate mission as signed
    _missionStorage.setMissionIsSigned(missionId, true);
    _missionStorage.setMissionBalance(missionId, 0);

    _token.transfer(
      _identity.getIdentityWallet(_missionStorage.getMissionSeller(missionId)),
      _missionStorage.getMissionCost(missionId)
    );
   
    // Event
    emit Signed(missionId);
  }

}
