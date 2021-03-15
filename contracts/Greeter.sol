// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

// 问候合约
contract Greeter {
    address private creator;
    uint256 private greeting;

    event UpdateGreet(uint256 newGreeting);
    event UpdateGreetAfter(uint256 newGreeting);

    constructor() public {
        creator = msg.sender;
    }

    function greet() public view returns (uint256) {
        return greeting;
    }

    function setGreeting(uint256 _newGreeting) public {
        require(creator == msg.sender);
        emit UpdateGreet(greeting);
        greeting = _newGreeting;
        emit UpdateGreetAfter(greeting + 1);
    }
}