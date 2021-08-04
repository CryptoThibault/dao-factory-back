// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

import "./Governance.sol";
import "./GovernanceToken.sol";
import "./Treasury.sol";

import "@openzeppelin/contracts/access/AccessControl.sol";

contract Dao is AccessControl {
    Governance private _governance;
    GovernanceToken private _token;
    Treasury private _treasury;

    constructor(
        address initialOwner,
        uint256 initialSupply,
        string memory tokenName,
        string memory tokenSymbol
    ) {
        _governance = new Governance();
        _token = new GovernanceToken(initialOwner, initialSupply, tokenName, tokenSymbol);
        _treasury = new Treasury();
    }
}
