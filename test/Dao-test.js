const { expect } = require('chai');
const { ethers } = require('hardhat');

describe('Dao', async function () {
  let Dao, dao, dev, alice;
  const TOKEN_NAME = 'Business 1 Token';
  const TOKEN_SYMBOL = 'BS1';
  const DEFAULT_ADMIN_ROLE = ethers.utils.id('DEFAULT_ADMIN_ROLE');
  const ADMIN_ROLE = ethers.utils.id('ADMIN_ROLE');
  beforeEach(async function () {
    [dev, alice] = await ethers.getSigners();
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
  it('should create a new Management contract address', async function () {
    expect(await dao.managementAddress()).to.not.equal(ethers.constants.AddressZero);
  });
  it('should asign alice as default admin', async function () {
    expect(await dao.hasRole(DEFAULT_ADMIN_ROLE, alice.address)).to.equal(true);
  });
  it('should asign dev as admin', async function () {
    await dao.connect(alice).grantRole(ADMIN_ROLE, dev.address);
    expect(await dao.hasRole(ADMIN_ROLE, dev.address)).to.equal(true);
  });
});
