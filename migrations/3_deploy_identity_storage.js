var IdentityStorage = artifacts.require('./IdentityStorage.sol');

module.exports = async (deployer) => {
  deployer.deploy(IdentityStorage);
};
