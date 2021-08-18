// SPDX-License-Identifier: MIT

pragma solidity ^0.8.5;

import "@openzeppelin/contracts/utils/Address.sol";
import "./Access.sol";

contract Treasury is Access {
    using Address for address payable;
    struct Charge {
        string name;
        address sender;
        address receiver;
        uint256 amount;
        uint256 createdAt;
        bool active;
    }

    event Created(uint256 id, string name, address receiver, uint256 amount, uint256 timestamp);
    event Canceled(uint256 id, string name, address receiver, uint256 amount, uint256 timestamp);
    event Received(address sender, uint256 amount, uint256 timestamp);
    event Sended(address receiver, uint256 amount, uint256 timestamp);

    mapping(address => uint256) private _daoBalances;
    mapping(address => mapping(uint => Charge)) private _charges;
    mapping(address => uint) private _counters;

    function feed(address dao) public payable returns (bool) {
        _daoBalances[dao] += msg.value;
        return true;
    }

    function simpleTransfer(address dao, address receiver_, uint amount_) public onlyRole(TREASURIER_ROLE) returns (bool) {
        _daoBalances[dao] -= amount_;
        _daoBalances[receiver_] += amount_;
        emit Sended(receiver_, amount_, block.timestamp);
        return true;
    } 

    function addCharge(
        address dao_,
        string memory name_,
        address receiver_,
        uint256 amount_
    ) public onlyRole(TREASURIER_ROLE) returns (bool) {
        _counters[dao_]++;
        _charges[dao_][_counters[dao_]] = Charge({
            name: name_,
            sender: msg.sender,
            receiver: receiver_,
            amount: amount_,
            createdAt: block.timestamp,
            active: true
        });
        emit Created(_counters[dao_], name_, receiver_, amount_, block.timestamp);
        return true;
    }

    function changeSender(address dao, uint id, address newSender) public returns (bool) {
      require(msg.sender == senderOf(dao, id));
      _charges[dao][id].sender = newSender;
      return true;
    }

    function cancelCharge(address dao, uint256 id) public returns (bool) {
        require(msg.sender == senderOf(dao, id));
        _charges[dao][id].active = false;
        emit Canceled(id, nameOf(dao, id), receiverOf(dao, id), amountOf(dao, id), block.timestamp);
        return true;
    }

    function payCharge(address dao, uint256 id) public returns (bool) {
        require(msg.sender == senderOf(dao, id));
        require(activeOf(dao, id));
        uint256 amount = amountOf(dao, id);
        _daoBalances[dao] -= amount;
        _daoBalances[receiverOf(dao, id)] += amount;
        emit Sended(receiverOf(dao, id), amountOf(dao, id), block.timestamp);
        return true;
    }

    function withdraw(address dao, uint amount) public onlyRole(ADMIN_ROLE) returns (bool) {
      require(treasuryOf(dao) >= amount);
      _daoBalances[dao] -= amount;
      payable(msg.sender).sendValue(amount);
      return true;
    }

    function withdrawAll(address dao) public onlyRole(ADMIN_ROLE) returns (bool) {
      uint amount = treasuryOf(dao);
      _daoBalances[dao] = 0;
      payable(msg.sender).sendValue(amount);
      return true;
    }

    function treasuryOf(address dao) public view returns (uint) {
      return _daoBalances[dao];
    }

    function totalTreasury() public view returns (uint256) {
        return address(this).balance;
    }

   function senderOf(address dao, uint256 id) public view returns (address) {
        return _charges[dao][id].sender;
    }

    function nameOf(address dao, uint256 id) public view returns (string memory) {
        return _charges[dao][id].name;
    }

    function receiverOf(address dao, uint256 id) public view returns (address) {
        return _charges[dao][id].receiver;
    }

    function amountOf(address dao, uint256 id) public view returns (uint256) {
        return _charges[dao][id].amount;
    }

    function creationOf(address dao, uint256 id) public view returns (uint256) {
        return _charges[dao][id].createdAt;
    }

    function activeOf(address dao, uint256 id) public view returns (bool) {
        return _charges[dao][id].active;
    }
}
