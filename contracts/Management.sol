// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

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

    event Employed(uint256 id, address account, uint256 salary, uint256 timestamp);
    event Fired(uint256 id, address account, uint256 timestamp);
    event Payed(address account, uint256 amount, uint256 time, uint256 timestamp);

    mapping(address => uint256) private _employeesId;
    mapping(uint256 => Employee) private _employeesData;
    uint256 private _counter;

    function employ(address account_, uint256 salary_) public returns (bool) {
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
        _employeesData[idOf(account)] = Employee({account: address(0), salary: 0, employedAt: 0, lastPayout: 0});
        _employeesId[account] = 0;
        emit Fired(idOf(account), account, block.timestamp);
        return true;
    }

    function payout() public returns (bool) {
        require(lastPayoutOf(msg.sender) < block.timestamp);
        uint256 nbPayout = block.timestamp - lastPayoutOf(msg.sender) / INTERVAL;
        uint256 amount = salaryOf(msg.sender) * nbPayout;
        payable(msg.sender).sendValue(amount);
        emit Payed(msg.sender, amount, nbPayout, block.timestamp);
        return true;
    }

    function idOf(address account) public view returns (uint256) {
        require(_employeesId[account] != 0);
        return _employeesId[account];
    }

    function salaryOf(address account) public view returns (uint256) {
        return _employeesData[idOf(account)].salary;
    }

    function lastPayoutOf(address account) public view returns (uint256) {
        return _employeesData[idOf(account)].lastPayout;
    }
}
