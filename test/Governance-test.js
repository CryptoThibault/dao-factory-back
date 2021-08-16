/* eslint-disable no-unused-vars */

const { expect } = require('chai');
const { ethers } = require('hardhat');

describe('Governance', async function () {
  let DaoFactory, daoFactory, dev, alice, bob;
  beforeEach(async function () {
    [dev, alice, bob] = await ethers.getSigners();
    DaoFactory = await ethers.getContractFactory('DaoFactory');
    daoFactory = await DaoFactory.connect(dev).deploy();
    await daoFactory.deployed();
  });
});
