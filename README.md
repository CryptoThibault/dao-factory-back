# Dao Factory by Crypto Thibault

- Contracts Language: Solidity v0.8.6
- Test and Scripts Environnement: Hardhat v2.5.0

### Dependencies:

- @openzeppelin/contracts
- hardhat-docgen
- dotenv

### Test library

- Chai
- Ethers Js

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
