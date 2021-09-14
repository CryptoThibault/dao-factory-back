# Dao Factory by Crypto Thibault

- [Link to Dapp](https://dao-factory-dapp.netlify.app/)
- [Link to Front](https://github.com/CryptoThibault/dao-factory-front)
- [Contract DaoFactory](https://etherscan.io/address/0x7995999f5B63cFcf061EA472755C0ed7A9E9289C)

- Contracts Language: Solidity v0.8.6
- Test and Scripts Environnement: Hardhat v2.5.0

### Dependencies:

- @openzeppelin/contracts
- hardhat-waffle
- chai
- ethers
- hardhat-contract-sizer
- hardhat-docgen
- prettier
- eslint
- solhint
- dotenv

### Protocol Stucture

```
DaoFactory
├── Dao ── AccessControl
│   ├── Governance ── ERC20
│   ├── Treasury
│   └── Management
```

### Install Repository

```zsh
git clone https://github.com/CryptoThibault/dao-factory-back.git
yarn
```

### Add your environnement variable in .env

```
INFURA_PROJECT_ID=""
DEPLOYER_PRIVATE_KEY=""
```

### Compile and check test

```zsh
npx hardhat compile
npx hardhat test
```

### Run script on all Ethereum Testnet

```
npx hardhat run scripts/deploy-DaoFactory.js
```
