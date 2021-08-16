/* eslint-disable no-unused-vars */

const { expect } = require('chai');
const { ethers } = require('hardhat');

describe('Dao', async function () {
  let Dao, dao, dev, alice, bob;
  const TOKEN_NAME = 'Business 1 Token';
  const TOKEN_SYMBOL = 'BS1';
  const DEFAULT_ADMIN_ROLE = ethers.utils.id('DEFAULT_ADMIN_ROLE');
  beforeEach(async function () {
    [dev, alice, bob] = await ethers.getSigners();
    Dao = await ethers.getContractFactory('Dao');
    dao = await Dao.connect(dev).deploy(alice.address, TOKEN_NAME, TOKEN_SYMBOL);
    await dao.deployed();
  });
  it('should create a new Governance Token contract address', async function () {
    expect(await dao.tokenAddress()).to.not.equal(ethers.constants.AddressZero);
  });
  it('should create a new Governance contract address', async function () {
    expect(await dao.governanceAddress()).to.not.equal(ethers.constants.AddressZero);
  });
  it('should asign alice as default admin of this dao', async function () {
    expect(await dao.hasRole(DEFAULT_ADMIN_ROLE, alice.address)).to.equal(true);
  });
});
