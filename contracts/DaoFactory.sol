// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "./Dao.sol";

/// @dev Contract DaoFactory is used to deploy Dao contract for each Business struct created
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

    /// @dev use to create a business structure with differents values
    /// @param name_ name of your business
    /// @param url_ url of your business
    /// @param tokenName name of Governance Token
    /// @param tokenSymbol symbol of Governance Token
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

    /// @param id place on _businessId mapping
    /// @return name of this business
    function nameOf(uint256 id) public view returns (string memory) {
        return _businessId[id].name;
    }

    /// @param id place on _businessId mapping
    /// @return url of this business
    function urlOf(uint256 id) public view returns (string memory) {
        return _businessId[id].url;
    }

    /// @param id place on _businessId mapping
    /// @return author of this business
    function authorOf(uint256 id) public view returns (address) {
        return _businessId[id].author;
    }

    /// @param id place on _businessId mapping
    /// @return creation timestamp of this business
    function creationOf(uint256 id) public view returns (uint256) {
        return _businessId[id].createdAt;
    }

    /// @param id place on _businessId mapping
    /// @return address of the dao contract of this business
    function daoAddressOf(uint256 id) public view returns (address) {
        return address(_businessId[id].dao);
    }

    /// @return id of the last business created
    function lastId() public view returns (uint256) {
        return _counter;
    }
}
