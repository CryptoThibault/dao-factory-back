// SPDX-License-Identifier: MIT

pragma solidity ^0.8.5;

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
        string memory tokenName,
        string memory tokenSymbol
    ) public returns (bool) {
        _counter++;
        Dao newDao = new Dao(msg.sender, tokenName, tokenSymbol);
        _businessId[_counter] = Business({
            name: name_,
            url: url_,
            author: msg.sender,
            createdAt: block.timestamp,
            dao: newDao
        });
        emit Created(_counter, name_, url_, msg.sender, block.timestamp, daoAddressOf(_counter)); 
        return true;
    }
    function nameOf(uint256 id) public view returns (string memory) {
        return _businessId[id].name;
    }
    function urlOf(uint256 id) public view returns (string memory) {
        return _businessId[id].url;
    }
    function authorOf(uint256 id) public view returns (address) {
        return _businessId[id].author;
    }
    function creationOf(uint256 id) public view returns (uint256) {
        return _businessId[id].createdAt;
    }
    function daoAddressOf(uint256 id) public view returns (address) {
        return address(_businessId[id].dao);
    }
    function lastId() public view returns (uint256) {
        return _counter;
    }
}
