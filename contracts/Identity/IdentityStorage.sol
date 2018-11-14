
pragma solidity 0.4.24;

import 'openzeppelin-solidity/contracts/ownership/Ownable.sol';
import '../interfaces/IIdentityStorage.sol';

library IdentityStruct {
  struct DAVIdentity {
    address wallet;
    mapping (address => bool) mission_contracts;
  }    
}

contract IdentityStorage is IIdentityStorage, Ownable {

  address _latestVersion;

  mapping (address => IdentityStruct.DAVIdentity) private identities;

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

  function createIdentity(address id, address wallet) external onlyLatestVersion {
    // Register in identities mapping
    identities[id].wallet = wallet;
  }

  function identityHasMissionType(address id, address missionContract) external view returns(bool) {
    return identities[id].mission_contracts[missionContract];
  }

  function identityAddMissionType(address id, address missionContract) external onlyLatestVersion {
    // Register in identities mapping
    identities[id].mission_contracts[missionContract] = true;
  }

  function getIdentityWallet(address id) external view returns(address) {
    return identities[id].wallet;
  }
}