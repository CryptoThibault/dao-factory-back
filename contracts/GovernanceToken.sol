// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract GovernanceToken is ERC20 {
    constructor(
        address owner,
        uint256 initialSupply,
        string memory name,
        string memory symbol
    ) ERC20(name, symbol) {
        _mint(owner, initialSupply);
    }

    function mint(address to, uint256 amount) public view returns(bool) {
        _mint(to, amount);
        return true;
    }
    function burn(address from, uint256 amount) public view returns(bool) {
        require(balanceOf(from) >= amount);
        _burn(from, amount);
        return true;
    }
}
