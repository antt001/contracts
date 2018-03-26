pragma solidity ^0.4.18;

import './PausableCrowdsale.sol';
import 'zeppelin-solidity/contracts/crowdsale/validation/TimedCrowdsale.sol';
import './interfaces/IDAVToken.sol';

/**
 * @title DAVCrowdsale
 * @dev DAV Crowdsale contract
 */
contract DAVCrowdsale is PausableCrowdsale, TimedCrowdsale {

  uint256 public minimalContribution;

  function DAVCrowdsale(uint256 _rate, address _wallet, IDAVToken _token, uint256 _minimalContribution, uint256 _openingTime, uint256 _closingTime) public
    Crowdsale(_rate, _wallet, _token)
    TimedCrowdsale(_openingTime, _closingTime)
  {
    minimalContribution = _minimalContribution;
  }

  function _preValidatePurchase(address _beneficiary, uint256 _weiAmount) internal {
    super._preValidatePurchase(_beneficiary, _weiAmount);
    // Verify amount is larger than minimal contribution
    require(_weiAmount >= minimalContribution);
  }

}
