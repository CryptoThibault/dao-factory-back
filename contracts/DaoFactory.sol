// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

import "./Dao.sol";

contract DaoFactory {
    struct Business {
        string name;
        string url;
        address author;
        uint256 createdAt;
        Dao dao;
    }

    event Created(uint256 id, string name, string url, address author, uint256 timestamp, address dao);

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
        emit(_counter, name_, url_, msg.sender, block.timestamp, daoAddressOf(_counter)); 
        return true;
    }

    function nameOf(uint256 id) public view returns (sting memory) {
        return _businessId[id].name;
    }

    function urlOf(uint256 id) public view returns (string memory) {
        return _businessId[id].url);
    }

    function authorOf(uint256 id) public view returns (address) {
        return _businessId[id].author;
    }

    function creationOf(uint256 id) public view returns (uint256) {
        return _businessId.createdAt;
    }

    function daoAddressOf(uint256 id) public view returns (address) {
        return address(_businessId[id].dao);
    }
}
