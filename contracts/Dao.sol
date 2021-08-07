// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

import "./Governance.sol";
import "./Access.sol";
import "./GovernanceToken.sol";
import "./Treasury.sol";
import "./Management.sol";

contract Dao {
    GovernanceToken private _token;
    Access private _access;
    Governance private _governance;
    Treasury private _treasury;
    Management private _management;

    uint256 public constant INTERVAL = 1 weeks;

    constructor(
        address initialOwner,
        uint256 initialSupply,
        string memory tokenName,
        string memory tokenSymbol
    ) {
        _token = new GovernanceToken(initialOwner, initialSupply, tokenName, tokenSymbol);
        _access = new Access(initialOwner);
        _governance = new Governance(address(_token), address(_access));
        _treasury = new Treasury();
        _management = new Management();
    }

    function tokenAddress() public view returns (address) {
        return address(_token);
    }

    function accessAddress() public view returns (address) {
        return address(_access);
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
