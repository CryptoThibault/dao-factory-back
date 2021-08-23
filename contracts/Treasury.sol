// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "./Dao.sol";
import "@openzeppelin/contracts/utils/Address.sol";

contract Treasury {
    using Address for address payable;
    struct Charge {
        string name;
        address receiver;
        uint256 amount;
        uint256 createdAt;
        bool active;
        uint256 counter;
    }

    event Created(uint256 id, string name, address receiver, uint256 amount, uint256 timestamp);
    event Canceled(uint256 id, string name, address receiver, uint256 amount, uint256 timestamp);
    event Received(address sender, uint256 amount, uint256 timestamp);
    event Sended(address receiver, uint256 amount, uint256 timestamp);

    Dao private _dao;
    mapping(uint256 => Charge) private _charges;
    uint256 private _counter;

    constructor() {
        _dao = Dao(msg.sender);
    }

    function feed() public payable {
        emit Received(msg.sender, msg.value, block.timestamp);
    }

    function simpleTransfer(address receiver_, uint256 amount_) public returns (bool) {
        require(_dao.hasRole(_dao.TREASURIER_ROLE, msg.sender), "Treasury: only Treasurier Role can use this function");
        payable(receiver_).sendValue(amount_);
        emit Sended(receiver_, amount_, block.timestamp);
        return true;
    }

    function addCharge(
        string memory name_,
        address receiver_,
        uint256 amount_
    ) public returns (bool) {
        require(_dao.hasRole(_dao.TREASURIER_ROLE, msg.sender), "Treasury: only Treasurier Role can use this function");
        _counter++;
        _charges[_counter] = Charge({
            name: name_,
            receiver: receiver_,
            amount: amount_,
            createdAt: block.timestamp,
            active: true,
            counter: 0
        });
        emit Created(_counter, name_, receiver_, amount_, block.timestamp);
        return true;
    }

    function cancelCharge(uint256 id) public returns (bool) {
        require(_dao.hasRole(_dao.TREASURIER_ROLE, msg.sender), "Treasury: only Treasurier Role can use this function");
        _charges[id].active = false;
        emit Canceled(id, nameOf(id), receiverOf(id), amountOf(id), block.timestamp);
        return true;
    }

    function payCharge(uint256 id) public returns (bool) {
        require(_dao.hasRole(_dao.TREASURIER_ROLE, msg.sender), "Treasury: only Treasurier Role can use this function");
        require(activeOf(id));
        _charges[id].counter++;
        payable(receiverOf(id)).sendValue(amountOf(id));
        emit Sended(receiverOf(id), amountOf(id), block.timestamp);
        return true;
    }

    function totalTreasury() public view returns (uint256) {
        return address(this).balance;
    }

    function nameOf(uint256 id) public view returns (string memory) {
        return _charges[id].name;
    }

    function receiverOf(uint256 id) public view returns (address) {
        return _charges[id].receiver;
    }

    function amountOf(uint256 id) public view returns (uint256) {
        return _charges[id].amount;
    }

    function creationOf(uint256 id) public view returns (uint256) {
        return _charges[id].createdAt;
    }

    function activeOf(uint256 id) public view returns (bool) {
        return _charges[id].active;
    }

    function counterOf(uint256 id) public view returns (uint256) {
        return _charges[id].counter;
    }
}
