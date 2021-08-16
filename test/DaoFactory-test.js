/* eslint-disable no-unused-vars */

const { expect } = require('chai');
const { ethers } = require('hardhat');

describe('DaoFactory', async function () {
  let DaoFactory, daoFactory, dev, alice, bob;
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
    await daoFactory.connect(alice).create(NAME, URL, TOKEN_NAME, TOKEN_SYMBOL);
  });

  it('should create a Business with good name', async function () {
    expect(await daoFactory.nameOf(ID)).to.equal(NAME);
  });
  it('should create a Business with good url', async function () {
    expect(await daoFactory.urlOf(ID)).to.equal(URL);
  });
  it('should create a Business with good author', async function () {
    expect(await daoFactory.authorOf(ID)).to.equal(alice.address);
  });
  it('should create a Business with good creation date', async function () {
    expect(await daoFactory.creationOf(ID)).to.above(0);
  });
  it('should create a Business with a new Dao contract address', async function () {
    expect(await daoFactory.daoAddressOf(ID)).to.not.equal(ethers.constants.AddressZero);
  });
});
