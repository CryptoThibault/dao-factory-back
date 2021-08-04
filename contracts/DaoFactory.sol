// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

import "./Dao.sol";

contract DaoFactory {
    struct Business {
        string name;
        string url;
        address author;
        uint256 creation;
        Dao dao;
    }

    mapping(uint256 => Business) private _businessId;
    uint256 private _counter;

    function create(
        string memory name_,
        string memory url_,
        uint256 initialSupply,
        string memory tokenName,
        string memory tokenSymbol
    ) public returns (bool) {
        _counter++;
        _businessId[_counter] = Business({
            name: name_,
            url: url_,
            author: msg.sender,
            creation: block.timestamp,
            dao: new Dao(msg.sender, initialSupply, tokenName, tokenSymbol)
        });
        return true;
    }

    function daoAddressOf(uint256 id) public view returns (address) {
        return address(_businessId[id].dao);
    }
}
