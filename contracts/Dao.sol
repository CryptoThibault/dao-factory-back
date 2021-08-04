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

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");
    bytes32 public constant EMPLOYEE_ROLE = keccak256("EMPLOYEE_ROLE");

    constructor(
        address initialOwner,
        uint256 initialSupply,
        string memory tokenName,
        string memory tokenSymbol
    ) {
        _setRoleAdmin(ADMIN_ROLE, DEFAULT_ADMIN_ROLE);
        _setupRole(ADMIN_ROLE, initialOwner);
        _governance = new Governance();
        _token = new GovernanceToken(initialOwner, initialSupply, tokenName, tokenSymbol);
        _treasury = new Treasury();
    }

    function governanceAddress() public view returns (address) {
        return address(_governance);
    }

    function tokenAddress() public view returns (address) {
        return address(_token);
    }

    function treasuryAddress() public view returns (address) {
        return address(_treasury);
    }
}
