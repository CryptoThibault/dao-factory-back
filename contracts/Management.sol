// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "./Dao.sol";
import "@openzeppelin/contracts/utils/Address.sol";

/// @dev Management contract is used to manage employees and there salary is a specific Dao
contract Management {
    using Address for address payable;
    uint256 public constant INTERVAL = 1 weeks;
    struct Employee {
        address account;
        uint256 salary;
        uint256 employedAt;
        uint256 nextPayout;
    }

    event Received(address sender, uint256 amount);
    event Withdrew(address receiver, uint256 amount);
    event Employed(uint256 id, address account, uint256 salary);
    event Fired(uint256 id, address account);
    event Resigned(uint256 id, address account);
    event Payed(address account, uint256 amount, uint256 nbPayout, uint256 timestamp);

    Dao private _dao;
    mapping(address => uint256) private _employeesId;
    mapping(uint256 => Employee) private _employeesData;
    uint256 private _counter;

    /// @dev msg.sender is the Dao contract who deploy this one
    constructor() {
        _dao = Dao(msg.sender);
    }

    /// @dev feed contract with ethers as msg.value
    function feed() public payable {
        emit Received(msg.sender, msg.value);
    }

    /// @dev mananager can employ any address and set a salary
    /// @param account_ who will be employed
    /// @param salary_ for this account
    function employ(address account_, uint256 salary_) public returns (bool) {
        require(_dao.hasRole(_dao.MANAGER_ROLE(), msg.sender), "Management: only Manager Role can use this function");
        require(account_ != msg.sender, "Management: cannot employ yourself");
        _counter++;
        _employeesId[account_] = _counter;
        _employeesData[_counter] = Employee({
            account: account_,
            salary: salary_,
            employedAt: block.timestamp,
            nextPayout: block.timestamp + INTERVAL
        });
        emit Employed(_counter, account_, salary_);
        return true;
    }

    /// @dev manager can unemploy a curent employee
    /// @param account who will loose his salary
    function fire(address account) public returns (bool) {
        require(_dao.hasRole(_dao.MANAGER_ROLE(), msg.sender), "Management: only Manager Role can use this function");
        _employeesData[idOf(account)] = Employee({account: address(0), salary: 0, employedAt: 0, nextPayout: 0});
        _employeesId[account] = 0;
        emit Fired(idOf(account), account);
        return true;
    }

    /// @dev a user can resign from his job
    function resign() public returns (bool) {
        _employeesData[idOf(msg.sender)] = Employee({account: address(0), salary: 0, employedAt: 0, nextPayout: 0});
        _employeesId[msg.sender] = 0;
        emit Resigned(idOf(msg.sender), msg.sender);
        return true;
    }

    /// @dev employed user can use this function to receive there current salary
    function payout() public returns (bool) {
        require(nextPayoutOf(msg.sender) <= block.timestamp, "Management: employee have to wait his next payout");
        uint256 nbPayout = 0;
        for (uint256 i = nextPayoutOf(msg.sender); i < block.timestamp; i += INTERVAL) {
            nbPayout++;
        }
        uint256 amount = salaryOf(msg.sender) * nbPayout;
        _employeesData[idOf(msg.sender)].nextPayout = block.timestamp + INTERVAL;
        payable(msg.sender).sendValue(amount);
        emit Payed(msg.sender, amount, nbPayout, block.timestamp);
        return true;
    }

    /// @dev admin can withdraw ethers from this contract
    /// @param amount who will be withdrew
    function withdraw(uint256 amount) public returns (bool) {
        require(_dao.hasRole(_dao.ADMIN_ROLE(), msg.sender), "Management: only Admin Role can use this function");
        require(address(this).balance >= amount, "Management: cannot withdraw more than total treasury");
        payable(msg.sender).sendValue(amount);
        emit Withdrew(msg.sender, amount);
        return true;
    }

    /// @dev admin can withdraw all ethers from this contract
    function withdrawAll() public returns (bool) {
        require(_dao.hasRole(_dao.ADMIN_ROLE(), msg.sender), "Management: only Admin Role can use this function");
        uint256 amount = address(this).balance;
        payable(msg.sender).sendValue(amount);
        emit Withdrew(msg.sender, amount);
        return true;
    }

    /// @param id of the employee
    /// @return account of the employee
    function accountAt(uint256 id) public view returns (address) {
        return _employeesData[id].account;
    }

    /// @param account that we want his id
    /// @return id of this account
    function idOf(address account) public view returns (uint256) {
        require(_employeesId[account] != 0, "Management: this account is not employeed here");
        return _employeesId[account];
    }

    /// @param account that we want his salary
    /// @return salary of this account
    function salaryOf(address account) public view returns (uint256) {
        return _employeesData[idOf(account)].salary;
    }

    /// @param account that we want his employement timestamp
    /// @return employment timestamp of this account
    function employmentOf(address account) public view returns (uint256) {
        return _employeesData[idOf(account)].employedAt;
    }

    /// @param account that we want his next payout timestamp
    /// @return next payout timestamp of this account
    function nextPayoutOf(address account) public view returns (uint256) {
        return _employeesData[idOf(account)].nextPayout;
    }

    /// @return id of the last employees with counter
    function nbEmployee() public view returns (uint256) {
        return _counter;
    }
}
