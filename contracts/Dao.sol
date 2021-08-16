// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "./Governance.sol";
import "./GovernanceToken.sol";
import "./Treasury.sol";
import "./Management.sol";


contract Dao is AccessControl {
    GovernanceToken private _token;
    Governance private _governance;
    Treasury private _treasury;
    Management private _management;

    uint256 public constant INTERVAL = 1 weeks;
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");
    bytes32 public constant TREASURIER_ROLE = keccak256("TREASURIER_ROLE");

    constructor(
        address admin,
        string memory tokenName,
        string memory tokenSymbol
    ) {
        _setupRole(DEFAULT_ADMIN_ROLE, admin);
        _token = new GovernanceToken(tokenName, tokenSymbol);
        _governance = new Governance(address(_token));
        _treasury = new Treasury();
        _management = new Management();
    }

    function tokenAddress() public view returns (address) {
        return address(_token);
    }

    function governanceAddress() public view returns (address) {
        return address(_governance);
    }

    function treasuryAddress() public view returns (address) {
        return address(_treasury);
    }

    function managementAddress() public view returns (address) {
        return address(_management);
    }
}
