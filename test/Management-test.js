/* eslint-disable no-unused-vars */

const { expect } = require('chai');
const { ethers } = require('hardhat');

describe('Management', async function () {
  let Management, management, dev, alice, bob;
  beforeEach(async function () {
    [dev, alice, bob] = await ethers.getSigners();
    Management = await ethers.getContractFactory('Management');
    management = await Management.connect(dev).deploy();
    await management.deployed();
  });
  describe('Employ', async function () { });
  describe('Payout', async function () { });
});
