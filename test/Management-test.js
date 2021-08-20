/* eslint-disable no-unused-vars */

const { expect } = require('chai');
const { ethers } = require('hardhat');

describe('Management', async function () {
  let Management, management, dev, alice, bob;
  const MANAGER_ROLE = ethers.utils.id('MANAGER_ROLE');
  const EMPLOYEE_ID = 1;
  const SALARY = ethers.utils.parseEther('0.01');
  beforeEach(async function () {
    [dev, alice, bob] = await ethers.getSigners();
    Management = await ethers.getContractFactory('Management');
    management = await Management.connect(dev).deploy();
    await management.deployed();
  });
  describe('Employ', async function () {
    beforeEach(async function () {
      await management.connect(dev).grantRole(MANAGER_ROLE, alice.address);
      await management.connect(alice).employ(bob.address, SALARY);
    });
    it('should employ bob with the good id', async function () {
      expect(await management.idOf(bob.address)).to.equal(EMPLOYEE_ID);
    });
    it('should employ bob with the good salary', async function () {
      expect(await management.salaryOf(bob.address)).to.equal(SALARY);
    });
    it('should employ bob with the good employment date', async function () {
      expect(await management.employmentOf(bob.address)).to.above(1);
    });
    it('should fire bob and revert when ask data', async function () {
      await management.connect(alice).fire(bob.address);
      await expect(management.idOf(bob.address)).to.be.revertedWith('Management: this account is not employeed here');
    });
    it('should fire bob and revert when ask data', async function () {
      await management.connect(bob).resign();
      await expect(management.idOf(bob.address)).to.be.revertedWith('Management: this account is not employeed here');
    });
  });
  describe('Payout', async function () { });
});
