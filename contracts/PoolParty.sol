// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

import PartyToken from "./PartyToken.sol";

// This interface is designed to be compatible with the Vyper version.
/// @notice This is the Ethereum 2.0 deposit contract interface.
/// For more information see the Phase 0 specification under https://github.com/ethereum/eth2.0-specs
interface IDepositContract {
    /// @notice A processed deposit event.
    event DepositEvent(
        bytes pubkey,
        bytes withdrawal_credentials,
        bytes amount,
        bytes signature,
        bytes index
    );

    /// @notice Submit a Phase 0 DepositData object.
    /// @param pubkey A BLS12-381 public key.
    /// @param withdrawal_credentials Commitment to a public key for withdrawals.
    /// @param signature A BLS12-381 signature.
    /// @param deposit_data_root The SHA-256 hash of the SSZ-encoded DepositData object.
    /// Used as a protection against malformed input.
    function deposit(
        bytes calldata pubkey,
        bytes calldata withdrawal_credentials,
        bytes calldata signature,
        bytes32 deposit_data_root
    ) external payable;

    /// @notice Query the current deposit root hash.
    /// @return The deposit root hash.
    function get_deposit_root() external view returns (bytes32);

    /// @notice Query the current deposit count.
    /// @return The deposit count encoded as a little endian 64-bit number.
    function get_deposit_count() external view returns (bytes memory);
}

contract PoolParty is PartyToken {

  public constant address DEPOSIT_CONTRACT = address(0);
  public constant uint MAX_STAKE = 32 ether;
  public uint totalStaked = 0;
  public bool stakeCommitted = false;

  mapping (address => uint) userStake;

  public immutable address owner;

  constructor() {
    owner = msg.sender;
  }

  function deposit() public payable {
    require(totalStaked <= MAX_STAKE);
    uint maxStake = totalStaked - MAX_STAKE;
    uint stakeAmount = min(msg.value, maxStake);
    totalStaked += stakeAmount;
    require(transfer(stakeAmount, msg.sender));
    if (msg.value > stakeAmount) {
      // refund any excess
      msg.sender.transfer(msg.value - stakeAmount);
    }
  }

  // allow withdrawal before the funds are staked
  function withdraw(uint amount) public payable {
    require(!stakeCommitted);
    require(balanceOf(msg.sender) >= amount);
    require(userStake[msg.sender] >= amount);
    tokenBalance[msg.sender] -= amount;
    tokenBalance[address(this)] += amount;
    emit Tranfer(msg.sender, address(this), amount);
    userStake[msg.sender] -= amount;
    totalStaked -= amount;
    msg.sender.transfer(amount);
  }

  function stake(
    bytes calldata pubkey,
    bytes calldata withdrawal_credentials,
    bytes calldata signature,
    bytes32 deposit_data_root
  ) public {
    require(msg.sender === owner);
    require(!stakeCommitted);
    require(totalStaked == MAX_STAKE);
    require(balanceOf(address(this)) == 0);
    // do the thing
    IDepositContract c = IDepositContract(DEPOSIT_CONTRACT);
    c.deposit{ value: MAX_STAKE }(pubkey, withdrawal_credentials, signature, deposit_data_root);
    stakeCommitted = true;
  }

  function min(uint a, uint b) public view returns (uint) {
    return a > b ? b : a;
  }
}
