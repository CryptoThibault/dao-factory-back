// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "./Dao.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/// @dev Governance contract is used to vote role changes proposals by using your Governance Token in a specific Dao
/// This contract inherit from ERC20 contract by OpenZeppelin
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

    event Locked(address account, uint256 amount);
    event Unlocked(address receiver, uint256 amount);
    event Proposed(address sender, string description, address account, bytes32 role, bool grant);
    event Voted(address sender, uint256 power);
    event Approved(uint256 id, uint256 nbYes);
    event Rejected(uint256 id, uint256 nbNo);

    Dao private _dao;
    mapping(address => uint256) private _lockBalances;
    mapping(address => mapping(uint256 => uint256)) private _voteUsed;
    mapping(uint256 => Proposal) private _proposals;
    uint256 private _counter;

    /// @dev importing back Dao contract with msg.sender as deployer of this contract
    /// Function interact with AccessControl of Dao contract
    /// @param name name of Governance Token
    /// @param symbol symbol of Governance Token
    constructor(string memory name, string memory symbol) ERC20(name, symbol) {
        _dao = Dao(msg.sender);
    }

    /// @dev dev Mint new tokens for a specific user
    /// @param to account who will receive tokens
    /// @param amount numbers of tokens who will be minted
    function mint(address to, uint256 amount) public returns (bool) {
        require(_dao.hasRole(_dao.MINTER_ROLE(), msg.sender), "Governance: only Minter Role can use this function");
        _mint(to, amount);
        return true;
    }

    /// @dev dev Burn tokens for a specific user
    /// @param from account who will loose tokens
    /// @param amount numbers of tokens who will be burned
    function burn(address from, uint256 amount) public returns (bool) {
        require(_dao.hasRole(_dao.BURNER_ROLE(), msg.sender), "Governance: only Burner Role can use this function");
        _burn(from, amount);
        return true;
    }

    ///@dev lock tokens for increase votingPowerOf
    ///@param amount to lock (1 Token == 1 votingPowerOf)
    function lock(uint256 amount) public returns (bool) {
        transfer(address(this), amount);
        _lockBalances[msg.sender] += amount;
        emit Locked(msg.sender, amount);
        return true;
    }

    /// @dev unlock tokens but decrease votingPowerOf
    ///@param amount to unlock (1Token == 1 votingPowerOf)
    function unlock(uint256 amount) public returns (bool) {
        require(amount <= _lockBalances[msg.sender]);
        _lockBalances[msg.sender] -= amount;
        _approve(address(this), msg.sender, amount);
        transferFrom(address(this), msg.sender, amount);
        emit Unlocked(msg.sender, amount);
        return true;
    }

    /// @dev create a new proposal of grant or revoke a role in this dao
    /// @param description_ justify the current proposal
    /// @param account_ who will get the new role
    /// @param role_ given to the designed account
    /// @param grant_ boolean for choosing if user want grant or revoke a role
    function propose(
        string memory description_,
        address account_,
        bytes32 role_,
        bool grant_
    ) public returns (bool) {
        require(_dao.hasRole(_dao.PROPOSER_ROLE(), msg.sender), "Governance: only Proposer Role can use this function");
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
        emit Proposed(msg.sender, description_, account_, role_, grant_);
        return true;
    }

    /// @dev vote Yes or No to a specific proposal
    /// If the amount of Yes is superior to half of all the votingPower, the proposition will be approved.
    /// And same for amount of No, the proposition will be rejected.
    /// @param id of the proposal to vote on
    /// @param choice 0 Accept or 1 Reject (Yes or No)
    function vote(uint256 id, Choice choice) public returns (bool) {
        require(votingPowerOf(msg.sender) >= 1);
        require(voteUsedOf(msg.sender, id) < votingPowerOf(msg.sender));
        _voteUsed[msg.sender][id] += votingPowerOf(msg.sender);
        if (choice == Choice.Yes) {
            _proposals[id].nbYes += votingPowerOf(msg.sender);
        } else if (choice == Choice.No) {
            _proposals[id].nbNo += votingPowerOf(msg.sender);
        }
        emit Voted(msg.sender, votingPowerOf(msg.sender));
        if (nbYesOf(id) >= totalLock() / 2) {
            if (grantOf(id)) {
                _dao.grantRole(roleOf(id), accountOf(id));
            } else {
                _dao.revokeRole(roleOf(id), accountOf(id));
            }
            _proposals[id].status = Status.Approved;
            emit Approved(id, nbYesOf(id));
        } else if (nbNoOf(id) >= totalLock() / 2) {
            _proposals[id].status = Status.Rejected;
            emit Rejected(id, nbNoOf(id));
        }
        return true;
    }

    /// @param id of a proposal
    /// @return description of this proposal
    function descriptionOf(uint256 id) public view returns (string memory) {
        return _proposals[id].description;
    }

    /// @param id of a proposal
    /// @return account concerning by this proposal
    function accountOf(uint256 id) public view returns (address) {
        return _proposals[id].account;
    }

    /// @param id of a proposal
    /// @return role proposed for the account of this proposal
    function roleOf(uint256 id) public view returns (bytes32) {
        return _proposals[id].role;
    }

    /// @param id of a proposal
    /// @return grant or revoke a role with this proposal
    function grantOf(uint256 id) public view returns (bool) {
        return _proposals[id].grant;
    }

    /// @param id of a proposal
    /// @return author of this proposal
    function authorOf(uint256 id) public view returns (address) {
        return _proposals[id].author;
    }

    /// @param id of a proposal
    /// @return number of Yes by votingPowerOf for this proposal
    function nbYesOf(uint256 id) public view returns (uint256) {
        return _proposals[id].nbYes;
    }

    /// @param id of a proposal
    /// @return number of No by votingPowerOf for this proposal
    function nbNoOf(uint256 id) public view returns (uint256) {
        return _proposals[id].nbNo;
    }

    /// @param id of a proposal
    /// @return creation timestamp of this proposal
    function creationOf(uint256 id) public view returns (uint256) {
        return _proposals[id].createdAt;
    }

    /// @param id of a proposal
    /// @return status Running, Approved or Reject for this proposal
    function statusOf(uint256 id) public view returns (Status) {
        return _proposals[id].status;
    }

    /// @param account address of a user
    /// @return votingPowerOf of this user
    function votingPowerOf(address account) public view returns (uint256) {
        return _lockBalances[account];
    }

    /// @param account address of a user
    /// @param id of a proposal
    /// @return vote used by a user for this proposal
    function voteUsedOf(address account, uint256 id) public view returns (uint256) {
        return _voteUsed[account][id];
    }

    /// @return total of locked tokens on this contract
    function totalLock() public view returns (uint256) {
        return balanceOf(address(this));
    }

    /// @return id of the last proposal
    function nbProposal() public view returns (uint256) {
        return _counter;
    }
}
