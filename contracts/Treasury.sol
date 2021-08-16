// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

import "@openzeppelin/contracts/utils/Address.sol";

contract Treasury {
    using Address for address payable;
    struct Charge {
        string name;
        address receiver;
        uint256 amount;
        uint256 createdAt;
        bool active;
    }

    event Created(uint256 id, string name, address receiver, uint256 amount, uint256 timestamp);
    event Canceled(uint256 id, string name, address receiver, uint256 amount, uint256 timestamp);
    event Received(address sender, uint256 amount, uint256 timestamp);
    event Sended(address receiver, uint256 amount, uint256 timestamp);

    mapping(uint256 => Charge) private _charges;
    uint256 private _counter;

    function feed() public payable {
        emit Received(msg.sender, msg.value, block.timestamp);
    }

    function simpleTransfer(address receiver_, uint amount_) public returns (bool) {
        payable(receiver_).sendValue(amount_);
        emit Sended(receiver_, amount_, block.timestamp);
        return true;
    } 

    function addCharge(
        string memory name_,
        address receiver_,
        uint256 amount_
    ) public returns (bool) {
        _counter++;
        _charges[_counter] = Charge({
            name: name_,
            receiver: receiver_,
            amount: amount_,
            createdAt: block.timestamp,
            active: true
        });
        emit Created(_counter, name_, receiver_, amount_, block.timestamp);
        return true;
    }

    function cancelCharge(uint256 id) public returns (bool) {
        _charges[id].active = false;
        emit Canceled(id, nameAt(id), receiverAt(id), amountAt(id), block.timestamp);
        return true;
    }

    function payCharge(uint256 id) public returns (bool) {
        require(activeAt(id));
        payable(receiverAt(id)).sendValue(amountAt(id));
        emit Sended(receiverAt(id), amountAt(id), block.timestamp);
        return true;
    }

    function totalTreasury() public view returns (uint256) {
        return address(this).balance;
    }

    function nameAt(uint256 id) public view returns (string memory) {
        return _charges[id].name;
    }

    function receiverAt(uint256 id) public view returns (address) {
        return _charges[id].receiver;
    }

    function amountAt(uint256 id) public view returns (uint256) {
        return _charges[id].amount;
    }

    function creationAt(uint256 id) public view returns (uint256) {
        return _charges[id].createdAt;
    }

    function activeAt(uint256 id) public view returns (bool) {
        return _charges[id].active;
    }
}
