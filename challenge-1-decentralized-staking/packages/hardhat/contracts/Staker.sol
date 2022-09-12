// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;  //Do not change the solidity version as it negativly impacts submission grading

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";

contract Staker {

  ExampleExternalContract public exampleExternalContract;

  constructor(address exampleExternalContractAddress) {
      exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
  }

  modifier notCompleted() {
        require(deadline >= block.timestamp, "completed");
        _;
    }

  // Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
  // ( Make sure to add a `Stake(address,uint256)` event and emit it for the frontend <List/> display )
  mapping ( address => uint256 ) public balances;
  uint256 public constant threshold = 0.0001 ether;
  function stake() public payable notCompleted {
    require(msg.value >= threshold, "value less than threshold");
    balances[msg.sender] = msg.value;
  } 

  // After some `deadline` allow anyone to call an `execute()` function
  // If the deadline has passed and the threshold is met, it should call `exampleExternalContract.complete{value: address(this).balance}()`
  uint256 public deadline = block.timestamp + 30 seconds;
  function execute() external {
    require(block.timestamp > deadline, "before deadline");
    exampleExternalContract.complete{value: address(this).balance}();

    // delete balances[msg.sender];
    // deadline = block.timestamp + 30 seconds;
  } 


  // If the `threshold` was not met, allow everyone to call a `withdraw()` function to withdraw their balance
  function withdraw() external notCompleted {
    payable(msg.sender).transfer(balances[msg.sender]);
    balances[msg.sender] = 0; // set 0
  } 

  // Add a `timeLeft()` view function that returns the time left before the deadline for the frontend
  function timeLeft() external view returns (uint256) {
    return deadline >= block.timestamp ? deadline - block.timestamp : 0;
  } 

  // Add the `receive()` special function that receives eth and calls stake()
  receive() external payable {
    stake();
  }
}
