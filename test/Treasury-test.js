/* eslint-disable no-unused-vars */

const { expect } = require('chai');
const { ethers } = require('ethers');

describe('Treasury', async function () {
  let DaoFactory, daoFactory, dev, alice, bob;
  beforeEach(async function () {
    [dev, alice, bob] = await ethers.getSigners();
    DaoFactory = await ethers.getContractFactory('DaoFactory');
    daoFactory = await DaoFactory.connect(dev).deploy();
    await daoFactory.deployed();
  });
});
