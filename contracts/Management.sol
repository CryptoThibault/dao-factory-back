// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "./Dao.sol";
import "@openzeppelin/contracts/utils/Address.sol";

contract Management {
    using Address for address payable;
    uint256 public constant INTERVAL = 1 weeks;
    struct Employee {
        address account;
        uint256 salary;
        uint256 employedAt;
        uint256 lastPayout;
    }

    event Received(address sender, uint256 amount, uint256 timestamp);
    event Employed(uint256 id, address account, uint256 salary, uint256 timestamp);
    event Fired(uint256 id, address account, uint256 timestamp);
    event Resigned(uint256 id, address account, uint256 timestamp);
    event Payed(address account, uint256 amount, uint256 time, uint256 timestamp);

    Dao private _dao;
    mapping(address => uint256) private _employeesId;
    mapping(uint256 => Employee) private _employeesData;
    uint256 private _counter;

    constructor() {
        _dao = Dao(msg.sender);
    }

    function feed() public payable {
        emit Received(msg.sender, msg.value, block.timestamp);
    }

    function employ(address account_, uint256 salary_) public returns (bool) {
        require(_dao.hasRole(_dao.MANAGER_ROLE(), msg.sender), "Management: only Manager Role can use this function");
        require(account_ != msg.sender, "Management: cannot employ yourself");
        _counter++;
        _employeesId[account_] = _counter;
        _employeesData[_counter] = Employee({
            account: account_,
            salary: salary_,
            employedAt: block.timestamp,
            lastPayout: 0
        });
        emit Employed(_counter, account_, salary_, block.timestamp);
        return true;
    }

    function fire(address account) public returns (bool) {
        require(_dao.hasRole(_dao.MANAGER_ROLE(), msg.sender), "Management: only Manager Role can use this function");
        _employeesData[idOf(account)] = Employee({account: address(0), salary: 0, employedAt: 0, lastPayout: 0});
        _employeesId[account] = 0;
        emit Fired(idOf(account), account, block.timestamp);
        return true;
    }

    function resign() public returns (bool) {
        _employeesData[idOf(msg.sender)] = Employee({account: address(0), salary: 0, employedAt: 0, lastPayout: 0});
        _employeesId[msg.sender] = 0;
        emit Resigned(idOf(msg.sender), msg.sender, block.timestamp);
    }

    function payout() public returns (bool) {
        require(lastPayoutOf(msg.sender) < block.timestamp);
        uint256 timestamp = block.timestamp;
        uint256 nbPayout = timestamp - lastPayoutOf(msg.sender) / INTERVAL;
        uint256 amount = salaryOf(msg.sender) * nbPayout;
        _employeesData[idOf(msg.sender)].lastPayout = timestamp;
        payable(msg.sender).sendValue(amount);
        emit Payed(msg.sender, amount, nbPayout, timestamp);
        return true;
    }

    function withdraw(uint256 amount) public returns (bool) {
        require(_dao.hasRole(_dao.ADMIN_ROLE(), msg.sender), "Treasury: only Admin Role can use this function");
        require(totalTreasury() >= amount, "Treasury: cannot withdraw more than total treasury");
        payable(msg.sender).sendValue(amount);
        emit Withdrew(msg.sender, amount, block.timestamp);
        return true;
    }

    function withdrawAll() public returns (bool) {
        require(_dao.hasRole(_dao.ADMIN_ROLE(), msg.sender), "Treasury: only Admin Role can use this function");
        uint256 amount = totalTreasury();
        payable(msg.sender).sendValue(amount);
        emit Withdrew(msg.sender, amount, block.timestamp);
        return true;
    }

    function idOf(address account) public view returns (uint256) {
        require(_employeesId[account] != 0, "Management: this account is not employeed here");
        return _employeesId[account];
    }

    function salaryOf(address account) public view returns (uint256) {
        return _employeesData[idOf(account)].salary;
    }

    function employmentOf(address account) public view returns (uint256) {
        return _employeesData[idOf(account)].employedAt;
    }

    function lastPayoutOf(address account) public view returns (uint256) {
        return _employeesData[idOf(account)].lastPayout;
    }
}
