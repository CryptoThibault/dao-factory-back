// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Governance {
    IERC20 private _token;
    uint256 public constant INTERVAL = 1 weeks;
    enum Choice {
        Yes,
        No
    }
    enum Status {
        Running,
        Approved,
        Rejected
    }
    struct Proposal {
        uint256 nbYes;
        uint256 nbNo;
        uint256 createdAt;
        Status statu;
    }

    constructor(address token_) {
        _token = IERC20(token_);
    }

    mapping(uint256 => Proposal) private _proposals;
    mapping(address => uint256) private _lockedBalance;

    function lock(uint256 amount) public {
        _token.transferFrom(msg.sender, address(this), amount);
        _lockedBalance[msg.sender] += amount;
    }

    function unlock(uint256 amount) public {
        require(amount <= _lockedBalance[msg.sender]);
        _lockedBalance[msg.sender] -= amount;
        _token.transfer(msg.sender, amount);
    }
}
