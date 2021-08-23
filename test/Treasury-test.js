/* eslint-disable no-unused-vars */

const { expect } = require('chai');
const { ethers } = require('hardhat');

describe('Treasury', async function () {
  let Treasury, treasury, dev, alice, bob;
  const TREASURIER_ROLE = ethers.utils.id('TREASURIER_ROLE');
  const CHARGE_ID = 1;
  const CHARGE_NAME = 'Charge 1';
  const AMOUNT = ethers.utils.parseEther('0.01');
  beforeEach(async function () {
    [dev, alice, bob] = await ethers.getSigners();
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
  });
  describe('Pay Charge', async function () { });
  describe('Simple Transfer', async function () { });
});
