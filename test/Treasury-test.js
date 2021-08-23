/* eslint-disable no-unused-vars */

const { expect } = require('chai');
const { ethers } = require('hardhat');

describe('Treasury', async function () {
  let Dao, dao, Treasury, treasury, dev, alice, bob;
  const TOKEN_NAME = 'Business 1 Token';
  const TOKEN_SYMBOL = 'BS1';
  const TREASURIER_ROLE = ethers.utils.id('TREASURIER_ROLE');
  const CHARGE_ID = 1;
  const CHARGE_NAME = 'Charge 1';
  const AMOUNT = ethers.utils.parseEther('0.01');
  beforeEach(async function () {
    [dev, alice, bob] = await ethers.getSigners();
    Dao = await ethers.getContractFactory('Dao');
    dao = await Dao.connect(dev).deploy(dev.address, TOKEN_NAME, TOKEN_SYMBOL);
    await dao.deployed();
    Treasury = await ethers.getContractFactory('Treasury');
    treasury = await Treasury.connect(dev).deploy();
    await treasury.deployed();
  });
  describe('Create Charge', async function () {
    beforeEach(async function () {
      await treasury.connect(dev).grantRole(TREASURIER_ROLE, alice.address);
      await treasury.connect(alice).addCharge(CHARGE_NAME, bob.address, AMOUNT);
    });
    it('should create a charge with good name', async function () {
      expect(await treasury.nameOf(CHARGE_ID)).to.equal(CHARGE_NAME);
    });
    it('should create a charge with good receiver', async function () {
      expect(await treasury.receiverOf(CHARGE_ID)).to.equal(bob.address);
    });
    it('should create a charge with good amount', async function () {
      expect(await treasury.amountOf(CHARGE_ID)).to.equal(AMOUNT);
    });
    it('should create an active charge', async function () {
      expect(await treasury.activeOf(CHARGE_ID)).to.equal(true);
    });
  });
  describe('Pay Charge', async function () {
    let PAYCHARGE;
    beforeEach(async function () {
      await treasury.connect(dev).grantRole(TREASURIER_ROLE, alice.address);
      await treasury.connect(alice).addCharge(CHARGE_NAME, bob.address, AMOUNT);
      await treasury.connect(dev).feed({ value: AMOUNT });
      PAYCHARGE = await treasury.connect(alice).paycharge(CHARGE_ID);
    });
    it('should pay the charge to bob', async function () {
      expect(PAYCHARGE).to.changeEtherBalances([treasury, bob], [-AMOUNT, AMOUNT]);
    });
    it('should decrease total treasury', async function () {
      expect(await treasury.totalTreasury()).to.equal(0);
    });
    it('should update counter of this charge', async function () {
      expect(await treasury.counterOf(CHARGE_ID)).to.equal(1);
    });
    it('should disactive this charge', async function () {
      await treasury.connect(alice).cancelCharge(CHARGE_ID);
      expect(await treasury.activeOf(CHARGE_ID)).to.equal(false);
    });
  });
  describe('Simple Transfer', async function () { });
});
