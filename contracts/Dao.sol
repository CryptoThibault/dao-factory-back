// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "./Governance.sol";
import "./Treasury.sol";
import "./Management.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

/// @dev Contract Dao is used to interact with same roles on Governance, Treasury and Management contracts
/// This contract inherit from AccessControl contract by OpenZeppelin
contract Dao is AccessControl {
    Governance private _governance;
    Treasury private _treasury;
    Management private _management;

    /// @dev Role list for manage AccessControl of this Dao
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant PROPOSER_ROLE = keccak256("PROPOSER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");
    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");
    bytes32 public constant TREASURIER_ROLE = keccak256("TREASURIER_ROLE");

    /// @dev this constructor will deploy 3 others contract and setup the first role
    /// @param defaultAdmin first admin of this dao
    /// @param tokenName name of the Govenance Token
    /// @param tokenSymbol symbol of the Governance Token
    constructor(
        address defaultAdmin,
        string memory tokenName,
        string memory tokenSymbol
    ) {
        _setupRole(DEFAULT_ADMIN_ROLE, defaultAdmin);
        _governance = new Governance(tokenName, tokenSymbol);
        _setupRole(DEFAULT_ADMIN_ROLE, address(_governance));
        _treasury = new Treasury();
        _management = new Management();
    }

    /// @return address of Governance contract
    function governanceAddress() public view returns (address) {
        return address(_governance);
    }

    /// @return address of Treasury contract
    function treasuryAddress() public view returns (address) {
        return address(_treasury);
    }

    /// @return address of Management contract
    function managementAddress() public view returns (address) {
        return address(_management);
    }
}
