/* eslint-disable no-unused-vars */

const { expect } = require('chai');
const { ethers } = require('hardhat');

describe('GovernanceToken', async function () {
  let GovernanceToken, governanceToken, dev, alice, bob;
  beforeEach(async function () {
    [dev, alice, bob] = await ethers.getSigners();
    GovernanceToken = await ethers.getContractFactory('GovernanceToken');
    governanceToken = await GovernanceToken.connect(dev).deploy(alice.address);
    await governanceToken.deployed();
  });
});
