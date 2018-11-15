pragma solidity 0.4.24;

import '../interfaces/IIdentity.sol';
import '../interfaces/IDAVToken.sol';
import '../interfaces/IMissionStorage.sol';
import 'openzeppelin-solidity/contracts/math/SafeMath.sol';

/**
 * @title BasicMission
 * @dev The most basic contract for conducting Missions.
 *
 * This contract represents the very basic interface of a mission contract.
 * In the real world, there is very little reason to use this and not one of the
 * contracts that extend it. Consider this an interface, more than an implementation.
 */
contract RideHailingMission {

  using SafeMath for uint256;

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
  * @notice finalize a mission with actualPrice
  * @param missionId The id of the mission
  */
  function finalizeWithPrice(bytes32 missionId, uint256 actualPrice) public {
    // Verify that message sender controls the seller's wallet
    require(
      _identity.verifyOwnership(_missionStorage.getMissionSeller(missionId), msg.sender),
      'Transaction must be sent from seller\'s identity wallet'
    );
    
    require(
      _missionStorage.getMissionIsSigned(missionId) == false,
      'Mission is already finalized'
    );

    require(
      _missionStorage.getMissionDeposit(missionId) >= actualPrice,
      'Mission deposit is less then actual price'
    );

    require(
      _missionStorage.getMissionBalance(missionId) >= actualPrice,
      'Mission balance is less then actual price'
    );
    
    require(
      _token.balanceOf(this) >= actualPrice,
      'Insufficient token balance for payment in contract'
    );

    _missionStorage.setMissionActualPrice(missionId, actualPrice);

    // designate mission as signed
    _missionStorage.setMissionIsSigned(missionId, true);
    _missionStorage.setMissionBalance(missionId, _missionStorage.getMissionBalance(missionId).sub(actualPrice));

    _token.transfer(
      _identity.getIdentityWallet(_missionStorage.getMissionSeller(missionId)),
      actualPrice
    );

    uint256 change = _missionStorage.getMissionBalance(missionId);
    if(change > 0) {

      require(
        _token.balanceOf(this) >= change,
        'Insufficient token balance for change in contract'
      );

      _missionStorage.setMissionBalance(missionId, 0);
      _token.transfer(
        _identity.getIdentityWallet(_missionStorage.getMissionBuyer(missionId)),
        change
      );
    }
   
    // Event
    emit Signed(missionId);
  }

}
