pragma solidity ^0.8.7;

import "./Governance.sol";
import "./Treasury.sol";
import "./Management.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract Dao is AccessControl {
    Governance private _governance;
    Treasury private _treasury;
    Management private _management;

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant PROPOSER_ROLE = keccak256("PROPOSER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");
    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");
    bytes32 public constant TREASURIER_ROLE = keccak256("TREASURIER_ROLE");

    constructor(
        address defaultAdmin,
        string memory tokenName,
        string memory tokenSymbol
    ) {
        _setupRole(DEFAULT_ADMIN_ROLE, defaultAdmin);
        _governance = new Governance(defaultAdmin, tokenName, tokenSymbol);
        _treasury = new Treasury();
        _management = new Management();
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
