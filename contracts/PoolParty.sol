// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Token.sol";
import { IDepositContract } from "./interfaces/IDepositContract.sol";

contract PoolParty is Token {

  address public constant DEPOSIT_CONTRACT = address(0);
  uint public constant MAX_STAKE = 32 ether;
  uint public totalStaked = 0;
  bool public stakeCommitted = false;

  mapping (address => uint) userStake;

  address public immutable owner;

  constructor() {
    owner = msg.sender;
  }

  function deposit() public payable {
    require(totalStaked <= MAX_STAKE);
    uint maxStake = totalStaked - MAX_STAKE;
    uint stakeAmount = min(msg.value, maxStake);
    totalStaked += stakeAmount;
    require(transfer(msg.sender, stakeAmount));
    if (msg.value > stakeAmount) {
      // refund any excess
      payable(msg.sender).transfer(msg.value - stakeAmount);
    }
  }

  // allow withdrawal before the funds are staked
  function withdraw(uint amount) public payable {
    require(!stakeCommitted);
    require(balanceOf(msg.sender) >= amount);
    require(userStake[msg.sender] >= amount);
    tokenBalance[msg.sender] -= amount;
    tokenBalance[address(this)] += amount;
    emit Transfer(msg.sender, address(this), amount);
    userStake[msg.sender] -= amount;
    totalStaked -= amount;
    payable(msg.sender).transfer(amount);
  }

  function stake(
    bytes calldata pubkey,
    bytes calldata withdrawal_credentials,
    bytes calldata signature,
    bytes32 deposit_data_root
  ) public {
    require(msg.sender == owner);
    require(!stakeCommitted);
    require(totalStaked == MAX_STAKE);
    require(balanceOf(address(this)) == 0);
    // do the thing
    IDepositContract c = IDepositContract(DEPOSIT_CONTRACT);
    c.deposit{ value: MAX_STAKE }(pubkey, withdrawal_credentials, signature, deposit_data_root);
    stakeCommitted = true;
  }

  function min(uint a, uint b) public pure returns (uint) {
    return a > b ? b : a;
  }
}
