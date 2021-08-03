# Back Template for Dapp

Install with command line:
```zsh
yarn init -y
yarn add prettier prettier-plugin-solidity solhint yarn add --dev eslint eslint-config-standard eslint-plugin-import eslint-plugin-mocha-no-only eslint-plugin-node eslint-plugin-promise eslint-plugin-standard --dev hardhat --dev @nomiclabs/hardhat-ethers ethers @nomiclabs/hardhat-waffle ethereum-waffle chai @nomiclabs/hardhat-solhint --dev
npx hardhat
touch .gitignore .prettierrc .eslintrc .solhint.json .editorconfig
mkdir contracts test scripts
```

More Tools:
```zsh
yarn add @openzeppelin/contracts
```