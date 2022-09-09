// Get funds from users
// Withdraw funds
// Set a minimum funding value in USD

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import './PriceConverter.sol';

contract FundMe {

    using PriceConverter for uint256;

    uint256 public minimumUsd = 50 * 1e18;

    address[] public funders;
    mapping(address => uint256) public addressToAmountFunded;

    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner {
        // do this first
        require(msg.sender == owner, "Sender is not owner!");

        // do rest of the code!!
        _;
    }

    function fund() public payable {
        require(msg.value.getConversionRate() >= minimumUsd, "Didn't send enough!"); // 1e18 == 1 * 10 ** 18

        funders.push(msg.sender);
        addressToAmountFunded[msg.sender] = msg.value;
    }

    function withdraw() public onlyOwner  {
        for(uint256 funderIndex = 0; funderIndex < funders.length; funderIndex++){
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }

        funders = new address[](0);

        // transfer - throws error if more than 2300 gas is used
        // msg.sender = address
        // payable(msg.sender) = payable address
        // payable(msg.sender).transfer(address(this).balance);

        // send - send returns boolean but doesn't throw error
        // bool sendSuccess = payable(msg.sender).send(address(this).balance);
        // require(sendSuccess, "Send failed");

        // call
        (bool callSuccess,) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call failed ");
    }
}
