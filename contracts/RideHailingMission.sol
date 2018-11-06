pragma solidity 0.4.24;

import './interfaces/IIdentity.sol';
import './interfaces/IDAVToken.sol';


/**
 * @title BasicMission
 * @dev The most basic contract for conducting Missions.
 *
 * This contract represents the very basic interface of a mission contract.
 * In the real world, there is very little reason to use this and not one of the
 * contracts that extend it. Consider this an interface, more than an implementation.
 */
contract RideHailingMission {

  uint256 private nonce;

  struct Mission {
    address seller;
    address buyer;
    uint256 tokenAmount;
    uint256 cost;
    uint256 balance;
    bool isSigned;
    mapping (uint8 => bool) resolvers;
  }

  mapping (bytes32 => Mission) private missions;

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
  constructor(IIdentity identityContract, IDAVToken davTokenContract) public {
    _identity = identityContract;
    _token = davTokenContract;
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
      _identity.verifyOwnership(buyerId, msg.sender)
    );

    // Verify buyer's balance is sufficient
    require(
      _identity.getBalance(buyerId) >= tokenAmount
    );

    // Make sure id isn't registered already
    require(
      missions[missionId].buyer == 0x0
    );

    // Transfer tokens to the mission contract
    _token.transferFrom(msg.sender, this, tokenAmount);

    // Create mission
    missions[missionId] = Mission({
      seller: sellerId,
      buyer: buyerId,
      tokenAmount: tokenAmount,
      cost: msg.value,
      balance: msg.value,
      isSigned: false
    });

    // Event
    emit Create(missionId, sellerId, buyerId);
  }

  /**
  * @notice Fund a mission
  * @param missionId The id of the mission
  */
  function fulfilled(bytes32 missionId) public {
    // Verify that message sender controls the seller's wallet
    require(
      _identity.verifyOwnership(missions[missionId].buyer, msg.sender)
    );
    
    require(
      missions[missionId].isSigned == false
    );

    require(
      missions[missionId].balance == missions[missionId].cost
    );
    
    require(
      address(this).balance >= missions[missionId].cost
    );
    
    // designate mission as signed
    missions[missionId].isSigned = true;
    missions[missionId].balance = 0;
    _token.burn(missions[missionId].tokenAmount);

    // transfer ETH to seller
    _identity.getIdentityWallet(missions[missionId].seller).transfer(missions[missionId].cost);

    // Event
    emit Signed(missionId);
  }

}
