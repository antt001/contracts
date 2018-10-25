var DAVToken = artifacts.require('./DAVToken.sol');
var Identity_v0 = artifacts.require('./Identity_v0.sol');
var BasicMission = artifacts.require('./BasicMission.sol');

module.exports = async (deployer) => {
  deployer.deploy(BasicMission, Identity_v0.address, DAVToken.address);
};
