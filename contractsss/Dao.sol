// SPDX-License-Identifier: MIT

pragma solidity ^0.8.5;

import "./Access.sol";
import "./Governance.sol";

contract Dao is Access {
    Governance private _governance;

    constructor(
        address defaultAdmin,
        string memory tokenName,
        string memory tokenSymbol
    ) {
        _setupRole(DEFAULT_ADMIN_ROLE, defaultAdmin);
        _governance = new Governance(address(this), tokenName, tokenSymbol);
    }

     function governanceAddress() public view returns (address) {
        return address(_governance);
    }
}
