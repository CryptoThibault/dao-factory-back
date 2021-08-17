// SPDX-License-Identifier: MIT

pragma solidity ^0.8.5;

import "@openzeppelin/contracts/utils/Address.sol";
import "./Access.sol";

contract Treasury is Access {
    using Address for address payable;
    struct Charge {
        address dao;
        address sender;
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

    mapping(address => uint256) private _daoBalances;
    mapping(uint256 => Charge) private _charges;
    uint256 private _counter;

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
        _counter++;
        _charges[_counter] = Charge({
            dao: dao_,
            sender: msg.sender,
            name: name_,
            receiver: receiver_,
            amount: amount_,
            createdAt: block.timestamp,
            active: true
        });
        emit Created(_counter, name_, receiver_, amount_, block.timestamp);
        return true;
    }

    function changeSender(uint id, address newSender) public returns (bool) {
      require(msg.sender == senderAt(id));
      _charges[id].sender = newSender;
      return true;
    }

    function cancelCharge(uint256 id) public returns (bool) {
        require(msg.sender == senderAt(id));
        _charges[id].active = false;
        emit Canceled(id, nameAt(id), receiverAt(id), amountAt(id), block.timestamp);
        return true;
    }

    function payCharge(uint256 id) public returns (bool) {
        require(msg.sender == senderAt(id));
        require(activeAt(id));
        uint256 amount = amountAt(id);
        _daoBalances[daoAt(id)] -= amount;
        _daoBalances[receiverAt(id)] += amount;
        emit Sended(receiverAt(id), amountAt(id), block.timestamp);
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

      function daoAt(uint256 id) public view returns (address) {
        return _charges[id].dao;
    }

   function senderAt(uint256 id) public view returns (address) {
        return _charges[id].sender;
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
