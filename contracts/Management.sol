// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

contract Management {
    uint256 public constant INTERVAL = 1 weeks;
    struct Employee {
        address account;
        uint256 salary;
        uint256 employedAt;
        uint256 lastPayout;
    }

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
        return true;
    }

    function fire(address account) public returns (bool) {
        _employeesData[idOf(account)] = Employee({account: address(0), salary: 0, employedAt: 0, lastPayout: 0});
        _employeesId[account] = 0;
        return true;
    }

    function idOf(address account) public view returns (uint256) {
        return _employeesId[account];
    }

    function salaryOf(address account) public view returns (uint256) {
        return _employeesData[idOf(account)].salary;
    }
}
