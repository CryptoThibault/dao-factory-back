/* eslint-disable no-unused-vars */

const { expect } = require('chai');
const { ethers } = require('hardhat');

describe('Treasury', async function () {
  let Treasury, treasury, dev, alice, bob;
  beforeEach(async function () {
    [dev, alice, bob] = await ethers.getSigners();
    Treasury = await ethers.getContractFactory('Treasury');
    treasury = await Treasury.connect(dev).deploy();
    await treasury.deployed();
  });
  describe('Create Charge', async function () { });
  describe('Pay Charge', async function () { });
  describe('Simple Transfer', async function () { });
});
