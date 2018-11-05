const accounts = web3.eth.accounts;

const signRegistrationMessage = (davId) => {
  const msg = 'DAV Identity Registration';
  return signMessage(davId, msg);
};

const signMessage = (id, msg) => {
  const hash = web3.sha3(msg);
  return signHash(id, hash);
}

const signHash = (id, hash) => {
  let signature = web3.eth.sign(id, hash).substr(2);
  return {
    id,
    r: '0x' + signature.slice(0, 64),
    s: '0x' + signature.slice(64, 128),
    v: web3.toDecimal('0x' + signature.slice(128, 130)) + 27
  };
}

const sampleIdentities = [
  signRegistrationMessage(accounts[0]),
  signRegistrationMessage(accounts[1])
];

const registerIdentity = (
  contract,
  walletAddress,
  id = sampleIdentities[0].id,
  v = sampleIdentities[0].v,
  r = sampleIdentities[0].r,
  s = sampleIdentities[0].s,
) => contract.register(id, v, r, s, {from: walletAddress});

module.exports = {
  sampleIdentities,
  registerIdentity,
  signMessage,
};
