var Identity_v0 = artifacts.require('./Identity_v0.sol');
const IdentityProxy = artifacts.require('./IdentityProxy.sol');

module.exports = async (deployer) => {
  deployer.deploy(IdentityProxy, Identity_v0.address);
};
