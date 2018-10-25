var DAVToken = artifacts.require('./DAVToken.sol');
var IdentityStorage = artifacts.require('./IdentityStorage.sol');
var Identity_v0 = artifacts.require('./Identity_v0.sol');

module.exports = async (deployer) => {
  deployer.deploy(Identity_v0, DAVToken.address, IdentityStorage.address);
};
