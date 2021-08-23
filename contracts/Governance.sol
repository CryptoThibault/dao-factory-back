// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "./Dao.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Governance is ERC20 {
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
        address account;
        bytes32 role;
        bool grant;
        uint256 nbYes;
        uint256 nbNo;
        address author;
        uint256 createdAt;
        Status status;
    }

    event Locked(address account, uint256 amount, uint256 timestamp);
    event Unlocked(address receiver, uint256 amount, uint256 timestamp);
    event Proposed(address sender, string description, uint256 timestamp);
    event Voted(address sender, uint256 power, uint256 timestamp);
    event Approved(uint256 id, uint256 nbYes, uint256 timestamp);
    event Rejected(uint256 id, uint256 nbNo, uint256 timestamp);

    Dao private _dao;
    mapping(address => uint256) private _lockBalances;
    mapping(address => mapping(uint256 => uint256)) private _voteUsed;
    mapping(uint256 => Proposal) private _proposals;
    uint256 private _counter;

    constructor(string memory name, string memory symbol) ERC20(name, symbol) {
        _dao = Dao(msg.sender);
    }

    function mint(address to, uint256 amount) public returns (bool) {
        require(_dao.hasRole(_dao.MINTER_ROLE, msg.sender), "Governance: only Minter Role can use this function");
        _mint(to, amount);
        return true;
    }

    function burn(address from, uint256 amount) public returns (bool) {
        require(_dao.hasRole(_dao.BURNER_ROLE, msg.sender), "Governance: only Burner Role can use this function");
        _burn(from, amount);
        return true;
    }

    function lock(uint256 amount) public returns (bool) {
        transferFrom(msg.sender, address(this), amount);
        _lockBalances[msg.sender] += amount;
        emit Locked(msg.sender, amount, block.timestamp);
        return true;
    }

    function unlock(uint256 amount) public returns (bool) {
        require(amount <= _lockBalances[msg.sender]);
        _lockBalances[msg.sender] -= amount;
        transfer(msg.sender, amount);
        emit Unlocked(msg.sender, amount, block.timestamp);
        return true;
    }

    function propose(
        string memory description_,
        address account_,
        bytes32 role_,
        bool grant_
    ) public returns (bool) {
        require(_dao.hasRole(_dao.PROPOSER_ROLE, msg.sender), "Governance: only Proposer Role can use this function");
        require(grant_ ? !_dao.hasRole(role_, account_) : _dao.hasRole(role_, account_));
        _counter++;
        _proposals[_counter] = Proposal({
            description: description_,
            account: account_,
            role: role_,
            grant: grant_,
            nbYes: 0,
            nbNo: 0,
            author: msg.sender,
            createdAt: block.timestamp,
            status: Status.Running
        });
        emit Proposed(msg.sender, description_, block.timestamp);
        return true;
    }

    function vote(uint256 id, Choice choice) public returns (bool) {
        require(votingPower(msg.sender) >= 1);
        require(voteUsedOf(msg.sender, id) < votingPower(msg.sender));
        _voteUsed[msg.sender][id] += votingPower(msg.sender);
        if (choice == Choice.Yes) {
            _proposals[id].nbYes += votingPower(msg.sender);
        } else if (choice == Choice.No) {
            _proposals[id].nbNo += votingPower(msg.sender);
        }
        emit Voted(msg.sender, votingPower(msg.sender), block.timestamp);
        if (nbYesOf(id) >= totalLock() / 2) {
            if (grantOf(id)) {
                _dao.grantRole(roleOf(id), accountOf(id));
            } else {
                _dao.revokeRole(roleOf(id), accountOf(id));
            }
            _proposals[id].status = Status.Approved;
            emit Approved(id, nbYesOf(id), block.timestamp);
        } else if (nbNoOf(id) >= totalLock() / 2) {
            _proposals[id].status = Status.Rejected;
            emit Rejected(id, nbNoOf(id), block.timestamp);
        }
        return true;
    }

    function descriptionOf(uint256 id) public view returns (string memory) {
        return _proposals[id].description;
    }

    function accountOf(uint256 id) public view returns (address) {
        return _proposals[id].account;
    }

    function roleOf(uint256 id) public view returns (bytes32) {
        return _proposals[id].role;
    }

    function grantOf(uint256 id) public view returns (bool) {
        return _proposals[id].grant;
    }

    function authorOf(uint256 id) public view returns (address) {
        return _proposals[id].author;
    }

    function nbYesOf(uint256 id) public view returns (uint256) {
        return _proposals[id].nbYes;
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
        return _lockBalances[account];
    }

    function voteUsedOf(address account, uint256 id) public view returns (uint256) {
        return _voteUsed[account][id];
    }

    function totalLock() public view returns (uint256) {
        return balanceOf(address(this));
    }
}
