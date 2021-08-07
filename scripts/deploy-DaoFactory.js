const hre = require('hardhat');
const { deployed } = require('./deployed');
const { ethers } = require('ethers');

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log('Deploying contracts with the account:', deployer.address);
  const DaoFactory = await hre.ethers.getContractFactory('DaoFactory');
  const daoFactory = await DaoFactory.deploy();
  await daoFactory.deployed();
  await deployed('DaoFactory', hre.network.name, daoFactory.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
