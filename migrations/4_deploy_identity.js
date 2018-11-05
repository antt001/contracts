var DAVToken = artifacts.require('./DAVToken.sol');
var IdentityStorage = artifacts.require('./IdentityStorage.sol');
var Identity = artifacts.require('./Identity_v0_1.sol');

module.exports = async (deployer) => {
  await deployer.deploy(Identity, DAVToken.address, IdentityStorage.address);
  await IdentityStorageContract.setLatestVersion(IdentityContract.address);
};
