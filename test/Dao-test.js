/* eslint-disable no-unused-vars */

const { expect } = require('chai');
const { ethers } = require('hardhat');

describe('Dao', async function () {
  let Dao, dao, dev, alice, bob;
  const TOKEN_NAME = 'Business 1 Token';
  const TOKEN_SYMBOL = 'BS1';
  beforeEach(async function () {
    [dev, alice, bob] = await ethers.getSigners();
    Dao = await ethers.getContractFactory('Dao');
    dao = await Dao.connect(dev).deploy(alice.address, TOKEN_NAME, TOKEN_SYMBOL);
    await dao.deployed();
  });
  it('should create a new Governance contract address', async function () {
    expect(await dao.governanceAddress()).to.not.equal(ethers.constants.AddressZero);
  });
  it('should create a new Treasury contract address', async function () {
    expect(await dao.treasuryAddress()).to.not.equal(ethers.constants.AddressZero);
  });
});
