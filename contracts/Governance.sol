// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./Access.sol";

contract Governance {
    IERC20 private _token;
    Access private _access;
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
        string description;
        uint256 nbYes;
        uint256 nbNo;
        uint256 createdAt;
        Status status;
    }

    event Locked(address sender, uint256 amount, uint256 timestamp);
    event Unlocked(address receiver, uint256 amount, uint256 timestamp);
    event Proposed(address sender, string description, uint256 timestamp);
    event Voted(address sender, uint256 power, uint256 timestamp);
    event Approved(uint256 id, uint256 nbYes, uint256  timestamp);
    event Rejected(uint256 id, uint256 nbNo, uint256 timestamp);

    mapping(uint256 => Proposal) private _proposals;
    mapping(address => uint256) private _lockedBalance;
    uint256 private _counter;
    uint256 private _totalLocked;

    constructor(address token_, address access_) {
        _token = IERC20(token_);
        _access = Access(access_);
    }

    function lock(uint256 amount) public returns (bool) {
        _token.transferFrom(msg.sender, address(this), amount);
        _lockedBalance[msg.sender] += amount;
        _totalLocked += amount;
        emit Locked(msg.sender, amount, block.timestamp);
        return true;
    }

    function unlock(uint256 amount) public returns (bool) {
        require(amount <= _lockedBalance[msg.sender]);
        _lockedBalance[msg.sender] -= amount;
        _totalLocked -= amount;
        _token.transfer(msg.sender, amount);
        emit Unlocked(msg.sender, amount, block.timestamp);
        return true;
    }

    function propose(string memory description_) public returns (bool) {
        _counter++;
        _proposals[_counter] = Proposal({
            description: description_,
            nbYes: 0,
            nbNo: 0,
            createdAt: block.timestamp,
            status: Status.Running
        })
        emit Proposed(msg.sender, description_, block.timestamp);
        return true;
    }

    function vote(uint256 id, Choice choice) public returns (bool) {
        if (choice == Choice.Yes) {
            _proposals[id].nbYes += votingPower(msg.sender);
        } else if (choice == Choice.No) {
            _proposals[id].nbNo += votingPower(msg.sender);
        }
        emit Voted(msg.sender, votingPower(msg.sender), block.timestamp)
        if (nbYes(id) >= totalPower() / 2) {
            _proposals[id].status = Status.Approved;
            emit Approved(id, nbYes(id), block.timestamp);
        }
        else if (nbNo(id) >= totalPower() / 2) {
            _proposals[id].status = Status.Rejected;
            emit Rejected(id, nbNo(id), block.timestamp);
        }
    }

    function descriptionOf(uint256 id) public view returns (string memory) {
        return _proposals[id].description;
    }
    function nbYesOf(uint256 id) public view returns (uint256) {
        return _proposals[id].nbYes;
    }
    function nbNoOf(uint256 id) public view returns (uint256) {
        return _proposals[id].nbNo;
    }
    function nbNoOf(uint256 id) public view returns (uint256) {
        return _proposals[id].nbNo;
    }
    function creationOf(uint256 id) public view returns (uint256) {
        return _proposals[id].createdAt;
    }
    function statusOf(uint256 id) public view returns (Status) {
        return _proposals[id].status;
    }

    function votingPower(address account) public view returns (uint256) {
        return _lockedBalance[account];
    }

    function totalPower() public view returns (uint256) {
        return _totalLocked;
    }

}
