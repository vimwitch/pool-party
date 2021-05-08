// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

contract PartyToken {
  mapping (address => uint) tokenBalance;
  mapping (address => uint) tokenAllowance;

  constructor() {
    tokenBalance[address(this)] = totalSupply();
  }

  function name() external view returns (string memory) {
    return "PartyEther";
  }

  function symbol() external view returns (string memory) {
    return "prETH";
  }

  function decimals() external view returns (uint8) {
    return 18;
  }

  function totalSupply() external view returns (uint) {
    return 32 ether;
  }

  function balanceOf(address owner) external view returns (uint) {
    return tokenBalance[owner];
  }

  function allowance(address owner, address spender) external view returns (uint) {
    return tokenAllowance[owner][spender];
  }

  function approve(address spender, uint value) external returns (bool) {
    tokenAllowance[msg.sender][spender] = value;
    emit Approval(msg.sender, spender, value);
    return true;
  }

  function transfer(address to, uint value) external returns (bool) {
    if (balanceOf(msg.sender) <= value) {
      return false;
    }
    tokenBalance[msg.sender] -= value;
    tokenBalance[to] += value;
    emit Transfer(msg.sender, to, value);
    return true
  }

  function transferFrom(address from, address to, uint value) external returns (bool) {
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
