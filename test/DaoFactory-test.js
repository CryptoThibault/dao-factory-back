/* eslint-disable no-unused-vars */

const { expect } = require('chai');
const { ethers } = require('ethers');

describe('DaoFactory', async function () {
  let DaoFactory, daoFactory, dev, alice, bob;
  beforeEach(async function () {
    [dev, alice, bob] = await ethers.getSigners();
    DaoFactory = await ethers.getContractFactory('DaoFactory');
    daoFactory = await DaoFactory.connect(dev).deploy();
    await daoFactory.deployed();
    await daoFactory.connect(alice).create('Business 1', 'https://www.business1',
      ethers.utils.parseEther('1000000'), 'Business 1 Token', 'BS1');
  });
  it('should create a Business after deploying', async function () {

  });
});
