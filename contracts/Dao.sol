// SPDX-License-Identifier: MIT

pragma solidity ^0.8.5;

import "./Access.sol";
import "./Governance.sol";
import "./GovernanceToken.sol";
import "./Treasury.sol";
import "./Management.sol";


contract Dao is Access {
    GovernanceToken private _token;
    Governance private _governance;
    Treasury private _treasury;
    Management private _management;

    uint256 public constant INTERVAL = 1 weeks;

    constructor(
        address defaultAdmin,
        string memory tokenName,
        string memory tokenSymbol
    ) {
        _setupRole(DEFAULT_ADMIN_ROLE, defaultAdmin);
        _token = new GovernanceToken(tokenName, tokenSymbol);
        _governance = new Governance(address(_token));
        //_treasury = new Treasury();
        //_management = new Management();
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
