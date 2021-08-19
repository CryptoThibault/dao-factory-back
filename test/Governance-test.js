/* eslint-disable no-unused-vars */

const { expect } = require('chai');
const { ethers } = require('hardhat');

describe('Governance', async function () {
  let Governance, governance, dev, alice, bob;
  const TOKEN_NAME = 'Business 1 Token';
  const TOKEN_SYMBOL = 'BS1';
  const AMOUNT = ethers.utils.parseEther('20');
  const LOCK_AMOUNT = ethers.utils.parseEther('10');
  const DEFAULT_ADMIN_ROLE = ethers.utils.id('DEFAULT_ADMIN_ROLE');
  const MINTER_ROLE = ethers.utils.id('MINTER_ROLE');
  const BURNER_ROLE = ethers.utils.id('BURNER_ROLE');

  beforeEach(async function () {
    [dev, alice, bob] = await ethers.getSigners();
    Governance = await ethers.getContractFactory('Governance');
    governance = await Governance.connect(dev).deploy(dev.address, TOKEN_NAME, TOKEN_SYMBOL);
    await governance.deployed();
  });
  it('should create token with the good name', async function () {
    expect(await governance.name()).to.equal(TOKEN_NAME);
  });
  it('should create token with the good symbol', async function () {
    expect(await governance.symbol()).to.equal(TOKEN_SYMBOL);
  });
  it('should asign dev as default admin', async function () {
    expect(await governance.hasRole(DEFAULT_ADMIN_ROLE, dev.address)).to.equal(true);
  });
  describe('Token Mint', async function () {
    beforeEach(async function () {
      await governance.connect(dev).grantRole(MINTER_ROLE, dev.address);
      await governance.mint(alice.address, AMOUNT);
    });
    it('should mint good amount for alice', async function () {
      expect(await governance.balanceOf(alice.address)).to.equal(AMOUNT);
    });
    it('should burn good amount for alice', async function () {
      await governance.connect(dev).grantRole(BURNER_ROLE, dev.address);
      await governance.connect(dev).burn(alice.address, AMOUNT);
      expect(await governance.balanceOf(alice.address)).to.equal(0);
    });
  });
  describe('Token Lock', async function () {
    beforeEach(async function () {
      await governance.connect(dev).grantRole(MINTER_ROLE, dev.address);
      await governance.mint(alice.address, AMOUNT);
      await governance.connect(alice).approve(governance.address, LOCK_AMOUNT);
    });
    it('should lock the good amount for alice', async function () {
      await governance.connect(alice).lock(LOCK_AMOUNT);
      expect(await governance.votingPowerOf(alice.address)).to.equal(LOCK_AMOUNT);
    });
  });
  describe('Proposal', async function () { });
  describe('Vote', async function () { });
});
