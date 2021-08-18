pragma solidity ^0.8.7;

import "./Access.sol";
import "./Governance.sol";
import "./Treasury.sol";

contract Dao is Access {
    Governance private _governance;
    Treasury private _treasury;

    constructor(
        address defaultAdmin,
        string memory tokenName,
        string memory tokenSymbol
    ) {
        _governance = new Governance(defaultAdmin, tokenName, tokenSymbol);
        _treasury = new Treasury();
    }

    function governanceAddress() public view returns (address) {
        return address(_governance);
    }

    function treasuryAddress() public view returns (address) {
        return address(_treasury);
    }
}
