// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

contract D {
    uint public x;
    constructor(uint a) public {
        x = a;
    }
}

contract Create2 {
    function createDSalted() public {
        /// 
        address pridectAddress = address(bytes20(keccak256(abi.encodePacked(
            byte(0xff),
            address(this),
            salt,
            keccak256(abi.encodePacked(
                type(D).createCode, 
                arg
            ))
        ))));

        D d = new D(salt: salt)(arg);
        require(address(d) == pridectAddress);
    }
}