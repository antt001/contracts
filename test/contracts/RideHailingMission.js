const Identity = artifacts.require('./Identity_v0_1.sol');
const IdentityStorage = artifacts.require('./IdentityStorage.sol');
const DAVToken = artifacts.require('./DAVToken.sol');
const RideHailingMissionStorage = artifacts.require('./RideHailingMissionStorage.sol');
const RideHailingMission = artifacts.require('./RideHailingMission.sol');
const uuid = require('uuid/v4');
const totalSupply = web3.toWei(1771428571, 'ether');

const { registerIdentity, sampleIdentities } = require('../helpers/identity');
const expectThrow = require('../helpers/assertRevert');

const deployContracts = async () => {
  const TokenContract = await DAVToken.new(totalSupply);
  // console.log('deploy IdentityStorageContract');
  const IdentityStorageContract = await IdentityStorage.new();
  // console.log('deploy IdentityContract');
  const IdentityContract = await Identity.new(TokenContract.address, IdentityStorageContract.address);
  // console.log('deploy Identity setLatestVersion');
  await IdentityStorageContract.setLatestVersion(IdentityContract.address);
  // console.log('deploy MissionContract');
  const RideHailingMissionStorageContract = await RideHailingMissionStorage.new();
  const MissionContract = await RideHailingMission.new(
    IdentityContract.address,
    TokenContract.address,
    RideHailingMissionStorageContract.address
  );
  await RideHailingMissionStorageContract.setLatestVersion(MissionContract.address);
  // console.log('deployment id done');
  return { TokenContract, IdentityContract, MissionContract };
};

contract('RideHailingMission', function(accounts) {
  let TokenContract;
  let IdentityContract;
  let MissionContract;
  let createEvent;
  let signedEvent;

  const user = {
    wallet: accounts[1],
    id: sampleIdentities[0].id,
    v: sampleIdentities[0].v,
    r: sampleIdentities[0].r,
    s: sampleIdentities[0].s,
  };

  const vehicle = {
    wallet: accounts[2],
    id: sampleIdentities[1].id,
    v: sampleIdentities[1].v,
    r: sampleIdentities[1].r,
    s: sampleIdentities[1].s,
  };

  beforeEach(async function() {
    ({
      TokenContract,
      IdentityContract,
      MissionContract,
    } = await deployContracts());

    createEvent = MissionContract.Create();
    signedEvent = MissionContract.Signed();

    // Create Identity for User
    await registerIdentity(
      IdentityContract,
      user.wallet,
      user.id,
      user.v,
      user.r,
      user.s,
    );

    // Create Identity for Vehicle
    await registerIdentity(
      IdentityContract,
      vehicle.wallet,
      vehicle.id,
      vehicle.v,
      vehicle.r,
      vehicle.s,
    );
  });

  it('should complete successfully when everything is in order', async function() {
    const userAirdropAmount = 20;
    const tokenAmount = 15;
    let userTokenBalance;
    // let vehicleTokenBalance;

    // Airdrop some money to User for testing
    userTokenBalance = await IdentityContract.getBalance.call(user.id);
    assert.equal(userTokenBalance.toNumber(), 0);
    await TokenContract.transfer(user.wallet, userAirdropAmount);
    userTokenBalance = await IdentityContract.getBalance.call(user.id);
    assert.equal(userTokenBalance.toNumber(), userAirdropAmount);

    // User funds basic mission and creates new basic mission
    await TokenContract.approve(MissionContract.address, tokenAmount, {from: user.wallet});
    // generate new unique 128bit id for bid
    let binaryId = new Array(16);
    uuid(null, binaryId, 0);
    let missionId = Buffer.from(binaryId).toString('hex');
    await MissionContract.create(missionId, vehicle.id, user.id, tokenAmount, {from: user.wallet});

    userTokenBalance = await IdentityContract.getBalance(user.id);
    assert.equal(userTokenBalance.toNumber(), userAirdropAmount-tokenAmount);

    // Event received (Create)
    const createdMissionId = (await createEvent.get())[0].args.id;
    assert.equal(Buffer.from(createdMissionId.substr(2), 'hex').toString(), missionId);
    
    await MissionContract.finalizeWithPrice(missionId, tokenAmount, {from: vehicle.wallet});
  
    // Event received (Signed)
    const events = await signedEvent.get();
    assert.equal(events.length, 1);
    assert.equal(events[0].args.id, '0x' + Buffer.from(missionId).toString('hex'));

    let vehicleTokenBalance = await IdentityContract.getBalance(vehicle.id);
    assert.equal(vehicleTokenBalance.toNumber(), tokenAmount);

    // Vehicle agrees to resolve mission

    // Event received

    // User agrees to resolve mission

    // Event received

    // userTokenBalance = await IdentityContract.getBalance(user.id);
    // assert.equal(userTokenBalance, userAirdropAmount-missionCost);
    // vehicleTokenBalance = await IdentityContract.getBalance(vehicle.id);
    // assert.equal(vehicleTokenBalance, missionCost);
  });

  describe('create', () => {
    const userAirdropAmount = 20;
    const missionCost = 4;
    const tokenAmount = 15;
    let missionId;
    beforeEach(async () => {
      // Airdrop some money to User for testing
      await TokenContract.transfer(user.wallet, userAirdropAmount);
      // User funds basic mission and creates new basic mission
      await TokenContract.approve(MissionContract.address, tokenAmount, {from: user.wallet});

      // generate new unique 128bit id for bid
      let binaryId = new Array(16);
      uuid(null, binaryId, 0);
      missionId = Buffer.from(binaryId).toString('hex');
    });

    it('should fire a Create event with the mission id, seller id, and buyer id', async () => {
      await MissionContract.create(missionId, vehicle.id, user.id, tokenAmount, {from: user.wallet, value: missionCost});

      const events = await createEvent.get();
      assert.equal(events.length, 1);
      assert.typeOf(events[0].args.id, 'string');
      assert.equal(events[0].args.id, '0x' + Buffer.from(missionId).toString('hex'));
      assert.equal(events[0].args.sellerId, vehicle.id);
      assert.equal(events[0].args.buyerId, user.id);
    });

    it('should throw if account creating the mission does not control the identity', async () => {
      await expectThrow(
        MissionContract.create(missionId, vehicle.id, user.id, tokenAmount, {
          from: vehicle.wallet,
          value: missionCost
        }),
      );
    });

    xit('should fail if cost is negative');
  });

  describe('approve', () => {
    let missionId;
    const userAirdropAmount = 20;
    const missionCost = 4;
    const tokenAmount = 15;

    beforeEach(async () => {
      // Airdrop some money to User for testing
      // generate new unique 128bit id for bid
      let binaryId = new Array(16);
      uuid(null, binaryId, 0);
      missionId = Buffer.from(binaryId).toString('hex');

      await TokenContract.transfer(user.wallet, userAirdropAmount);
      await TokenContract.approve(MissionContract.address, tokenAmount, {from: user.wallet});
      await MissionContract.create(missionId, vehicle.id, user.id, tokenAmount, {from: user.wallet, value: missionCost});
      // missionId = (await createEvent.get())[0].args.id;
    });

    xit('should set mission as signed', async () => {
      await MissionContract.finalizeWithPrice(missionId, tokenAmount, {from: vehicle.wallet});
      //TODO: chech if mission is signed or remove this test
    });

    it('should fire a Signed event', async () => {
      await MissionContract.finalizeWithPrice(missionId, tokenAmount, {from: vehicle.wallet});
      const events = await signedEvent.get();
      let createdMissionId = events[0].args.id;
      assert.equal(events.length, 1);
      assert.equal(Buffer.from(createdMissionId.substr(2), 'hex').toString(), missionId);
    });

    it('should deduct the cost from the balance of the buyer', async () => {
      const userTokenBalance = await IdentityContract.getBalance(user.id);
      assert.equal(userTokenBalance.toNumber(), userAirdropAmount - tokenAmount);
    });

    it('should fail if account finalizing the mission does not control seller id', async () => {
      await expectThrow(
        MissionContract.finalizeWithPrice(missionId, tokenAmount, {from: user.wallet})
      );
    });

    xit('should fail if account funding the mission does not have enough tokens');
    xit('should fail if buyer id and mission id do not match');
    xit('should increase the balance of the contract by the mission cost');

    it('should return correct change', async () => {
      let actualPrice = 10;
      await MissionContract.finalizeWithPrice(missionId, actualPrice, {from: vehicle.wallet});
      const events = await signedEvent.get();
      let createdMissionId = events[0].args.id;
      assert.equal(events.length, 1);
      assert.equal(Buffer.from(createdMissionId.substr(2), 'hex').toString(), missionId);

      let vehicleTokenBalance = await IdentityContract.getBalance(vehicle.id);
      assert.equal(vehicleTokenBalance.toNumber(), actualPrice);

      let userTokenBalance = await IdentityContract.getBalance(user.id);
      assert.equal(userTokenBalance.toNumber(), userAirdropAmount - actualPrice);
    });

  });

});
