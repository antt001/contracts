const DAVToken = artifacts.require('./mocks/DAVTokenMock.sol');
const expectThrow = require('./helpers/expectThrow');
const totalSupplySetting = 100;

contract('DAVToken', function(accounts) {

  it('should return the correct totalSupply after construction', async function() {
    let token = await DAVToken.new();
    let totalSupply = await token.totalSupply();
    assert.equal(totalSupply, totalSupplySetting);
  });

  it('should return the correct balanceOf after construction', async function() {
    let token = await DAVToken.new();
    let firstAccountBalance = await token.balanceOf(accounts[0]);
    assert.equal(firstAccountBalance, totalSupplySetting);
  });

  it('should transfer from sender when calling transfer()', async function() {
    let token = await DAVToken.new();
    await token.transfer(accounts[1], totalSupplySetting);
    let firstAccountBalance = (await token.balanceOf(accounts[0])).toNumber();
    let secondAccountBalance = (await token.balanceOf(accounts[1])).toNumber();
    assert.equal(firstAccountBalance, 0);
    assert.equal(secondAccountBalance, totalSupplySetting);
  });

  it('should throw an error when trying to transfer more than balance', async function() {
    let token = await DAVToken.new();
    await expectThrow(token.transfer(accounts[1], totalSupplySetting+1));
  });

  it('should throw an error when trying to transfer without approval', async function() {
    let token = await DAVToken.new();
    await expectThrow(token.transferFrom(accounts[1], accounts[0], 1));
  });

  it('should allow to transfer with transferFrom after approval but no more than approved amount', async function() {
    let token = await DAVToken.new();
    await token.approve(accounts[0], 2);
    await token.transferFrom(accounts[0], accounts[1], 1);
    await token.transferFrom(accounts[0], accounts[1], 1);
    await expectThrow(token.transferFrom(accounts[0], accounts[1], 1));
  });

  it('should return the correct allowance', async function() {
    let token = await DAVToken.new();
    assert.equal((await token.allowance(accounts[0], accounts[0])).toNumber(), 0);
    await token.approve(accounts[0], 1);
    assert.equal((await token.allowance(accounts[0], accounts[0])).toNumber(), 1);
    await token.transferFrom(accounts[0], accounts[1], 1);
    assert.equal((await token.allowance(accounts[0], accounts[0])).toNumber(), 0);
  });

  it('should be pausable and unpausable by owner', async function() {
    let token = await DAVToken.new();
    assert.equal(await token.paused(), false);
    await token.pause();
    assert.equal(await token.paused(), true);
    await token.unpause();
    assert.equal(await token.paused(), false);
  });

  it('should throw an error when trying to pause while paused', async function() {
    let token = await DAVToken.new();
    await token.pause();
    await expectThrow(token.pause());
    assert.equal(await token.paused(), true);
  });

  it('should throw an error when trying to unpause while not paused', async function() {
    let token = await DAVToken.new();
    await expectThrow(token.unpause());
    assert.equal(await token.paused(), false);
  });

});