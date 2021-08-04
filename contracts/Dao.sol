// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

import "./Governance.sol";
import "./GovernanceToken.sol";
import "./Treasury.sol";
import "./Management.sol";
import "./Access.sol";

contract Dao {
    GovernanceToken private _token;
    Governance private _governance;
    Treasury private _treasury;
    Management private _management;
    Access private _access;

    constructor(
        address initialOwner,
        uint256 initialSupply,
        string memory tokenName,
        string memory tokenSymbol
    ) {
        _token = new GovernanceToken(initialOwner, initialSupply, tokenName, tokenSymbol);
        _governance = new Governance(address(_token));
        _treasury = new Treasury();
        _management = new Management();
        _access = new Access(initialOwner);
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

    function managementAddress() public view returns (address) {
        return address(_management);
    }

    function accessAddress() public view returns (address) {
        return address(_access);
    }
}
