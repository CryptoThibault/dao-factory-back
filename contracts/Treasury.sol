// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "./Dao.sol";
import "@openzeppelin/contracts/utils/Address.sol";

/// @dev Treasury contract is used to manage charges and transfer of a specific Dao
contract Treasury {
    using Address for address payable;
    struct Charge {
        string name;
        address receiver;
        uint256 amount;
        uint256 createdAt;
        bool active;
        uint256 counter;
    }

    event Created(uint256 id, string name, address receiver, uint256 amount);
    event Canceled(uint256 id, string name, address receiver, uint256 amount);
    event Received(address sender, uint256 amount);
    event Withdrew(address reiceiver, uint256 amount);
    event Sended(address receiver, uint256 amount);

    Dao private _dao;
    mapping(uint256 => Charge) private _charges;
    uint256 private _counter;

    /// @dev msg.sender is the Dao contract who deploy this one
    constructor() {
        _dao = Dao(msg.sender);
    }

    /// @dev feed contract with ethers as msg.value
    function feed() public payable {
        emit Received(msg.sender, msg.value);
    }

    /// @dev treasurier can execute simple transfer of ethers from this contract to an ethereum address
    /// @param receiver_ who will receive ethers
    /// @param amount_ of ethers he will receive
    function simpleTransfer(address receiver_, uint256 amount_) public returns (bool) {
        require(
            _dao.hasRole(_dao.TREASURIER_ROLE(), msg.sender),
            "Treasury: only Treasurier Role can use this function"
        );
        payable(receiver_).sendValue(amount_);
        emit Sended(receiver_, amount_);
        return true;
    }

    /// @dev treasurier can create a new charge for this treasury
    /// @param name_ this charge
    /// @param receiver_ of this charge
    /// @param amount_ will be sent when used
    function addCharge(
        string memory name_,
        address receiver_,
        uint256 amount_
    ) public returns (bool) {
        require(
            _dao.hasRole(_dao.TREASURIER_ROLE(), msg.sender),
            "Treasury: only Treasurier Role can use this function"
        );
        _counter++;
        _charges[_counter] = Charge({
            name: name_,
            receiver: receiver_,
            amount: amount_,
            createdAt: block.timestamp,
            active: true,
            counter: 0
        });
        emit Created(_counter, name_, receiver_, amount_);
        return true;
    }

    /// @dev treasurier can cancel a current charge by seting active at false
    /// @param id of the charge will be canceled
    function cancelCharge(uint256 id) public returns (bool) {
        require(
            _dao.hasRole(_dao.TREASURIER_ROLE(), msg.sender),
            "Treasury: only Treasurier Role can use this function"
        );
        _charges[id].active = false;
        emit Canceled(id, nameOf(id), receiverOf(id), amountOf(id));
        return true;
    }

    /// @dev treasurier can sent stored amount to his receiver
    /// @param id of the charge
    function payCharge(uint256 id) public returns (bool) {
        require(
            _dao.hasRole(_dao.TREASURIER_ROLE(), msg.sender),
            "Treasury: only Treasurier Role can use this function"
        );
        require(activeOf(id), "Treasury: this charge are not active anymore");
        _charges[id].counter++;
        payable(receiverOf(id)).sendValue(amountOf(id));
        emit Sended(receiverOf(id), amountOf(id));
        return true;
    }

    /// @dev admin can withdraw ethers from this contract
    /// @param amount who will be withdrew
    function withdraw(uint256 amount) public returns (bool) {
        require(_dao.hasRole(_dao.ADMIN_ROLE(), msg.sender), "Treasury: only Admin Role can use this function");
        require(totalTreasury() >= amount, "Treasury: cannot withdraw more than total treasury");
        payable(msg.sender).sendValue(amount);
        emit Withdrew(msg.sender, amount);
        return true;
    }

    /// @dev admin can withdraw all ethers from this contract
    function withdrawAll() public returns (bool) {
        require(_dao.hasRole(_dao.ADMIN_ROLE(), msg.sender), "Treasury: only Admin Role can use this function");
        uint256 amount = totalTreasury();
        payable(msg.sender).sendValue(amount);
        emit Withdrew(msg.sender, amount);
        return true;
    }

    /// @return total treasury of this Dao
    function totalTreasury() public view returns (uint256) {
        return address(this).balance;
    }

    /// @param id of a charge
    /// @return name of this charge
    function nameOf(uint256 id) public view returns (string memory) {
        return _charges[id].name;
    }

    /// @param id of a charge
    /// @return receiver of this charge
    function receiverOf(uint256 id) public view returns (address) {
        return _charges[id].receiver;
    }

    /// @param id of a charge
    /// @return amount sent when this charge is used
    function amountOf(uint256 id) public view returns (uint256) {
        return _charges[id].amount;
    }

    /// @param id of a charge
    /// @return creation timestamp of this charge
    function creationOf(uint256 id) public view returns (uint256) {
        return _charges[id].createdAt;
    }

    /// @param id of a charge
    /// @return if this charge is usable of not
    function activeOf(uint256 id) public view returns (bool) {
        return _charges[id].active;
    }

    /// @param id of this charge
    /// @return how many time this charge was used
    function counterOf(uint256 id) public view returns (uint256) {
        return _charges[id].counter;
    }

    /// @return id of the last charge created
    function nbCharge() public view returns (uint256) {
        return _counter;
    }
}
