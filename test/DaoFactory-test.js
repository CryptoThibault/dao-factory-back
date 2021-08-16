/* eslint-disable no-unused-vars */

const { expect } = require('chai');
const { ethers } = require('hardhat');

describe('DaoFactory', async function () {
  let DaoFactory, daoFactory, dev, business1, alice, bob;
  const NAME = 'Business 1';
  const URL = 'https://www.business1';
  const TOKEN_NAME = `${NAME} Token`;
  const TOKEN_SYMBOL = 'BS1';
  const ID = 1;

  beforeEach(async function () {
    [dev, alice, bob] = await ethers.getSigners();
    DaoFactory = await ethers.getContractFactory('DaoFactory');
    daoFactory = await DaoFactory.connect(dev).deploy();
    await daoFactory.deployed();
    business1 = await daoFactory.connect(alice).create(NAME, URL, TOKEN_NAME, TOKEN_SYMBOL);
  });

  it('should create a Business with good name', async function () {
    expect(await daoFactory.nameOf(ID)).to.equal(NAME);
  });
});
