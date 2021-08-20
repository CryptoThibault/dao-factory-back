pragma solidity ^0.8.7;

import "./Access.sol";
import "./Governance.sol";
import "./Treasury.sol";
import "./Management.sol";

contract Dao is Access {
    Governance private _governance;
    Treasury private _treasury;
    Management private _management;

    constructor(
        address defaultAdmin,
        string memory tokenName,
        string memory tokenSymbol
    ) {
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
