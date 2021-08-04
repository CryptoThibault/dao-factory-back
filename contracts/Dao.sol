// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

import "./Governance.sol";
import "./GovernanceToken.sol";
import "./Treasury.sol";

import "@openzeppelin/contracts/access/AccessControl.sol";

contract Dao is AccessControl {
    GovernanceToken private _token;
    Governance private _governance;
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
        _token = new GovernanceToken(initialOwner, initialSupply, tokenName, tokenSymbol);
        _governance = new Governance(address(_token));
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
