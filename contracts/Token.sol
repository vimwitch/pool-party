// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { IERC20 } from './interfaces/IERC20.sol';

contract Token is IERC20 {
  mapping (address => uint) tokenBalance;
  mapping (address => mapping (address => uint)) tokenAllowance;

  constructor() {
    tokenBalance[address(this)] = totalSupply();
  }

  function name() public override pure returns (string memory) {
    return "PartyEther";
  }

  function symbol() public override pure returns (string memory) {
    return "prETH";
  }

  function decimals() public override pure returns (uint8) {
    return 18;
  }

  function totalSupply() public override pure returns (uint) {
    return 32 ether;
  }

  function balanceOf(address owner) public override view returns (uint) {
    return tokenBalance[owner];
  }

  function allowance(address owner, address spender) public override view returns (uint) {
    return tokenAllowance[owner][spender];
  }

  function approve(address spender, uint value) public override returns (bool) {
    tokenAllowance[msg.sender][spender] = value;
    emit Approval(msg.sender, spender, value);
    return true;
  }

  function transfer(address to, uint value) public override returns (bool) {
    if (balanceOf(msg.sender) < value) {
      return false;
    }
    tokenBalance[msg.sender] -= value;
    tokenBalance[to] += value;
    emit Transfer(msg.sender, to, value);
    return true;
  }

  function transferFrom(address from, address to, uint value) public override returns (bool) {
    if (tokenAllowance[from][msg.sender] < value) {
      return false;
    }
    if (balanceOf(from) < value) {
      return false;
    }
    tokenBalance[from] -= value;
    tokenBalance[to] += value;
    tokenAllowance[from][msg.sender] -= value;
    emit Transfer(from, to, value);
    return true;
  }

}
