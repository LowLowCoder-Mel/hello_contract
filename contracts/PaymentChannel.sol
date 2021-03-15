// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

// 支付合约
contract PaymentChannel {
    address payable public sender;
    address payable public recipient;
    uint256 public expiration;

    constructor(
        address payable _recipient, 
        uint256 duration
    ) public {
        sender = msg.sender;
        recipient = _recipient;
        expiration = now + duration;
    }

    function close(uint256 amount, bytes memory signaure) public {
        require(msg.sender == recipient);
        require(isValidSinature(amount, signaure));
        recipient.transfer(amount);
    }

    function extend(uint256 newExpiration) public {
        require(msg.sender == sender);
        require(newExpiration > expiration);
        expiration = newExpiration;
    }

    function claimTimeout() public {
        require(now > expiration);
        selfdestruct(sender);
    }

    function isValidSinature(uint256 amount, bytes memory signaure) 
        internal 
        view
        returns (bool)
    {
        bytes32 message = prefixed(keccak256(abi.encodePacked(this, amount)));
        return recoverSinger(message, signaure) == sender;
    }

    function splitSignature(bytes memory sig) 
        internal
        pure
        returns (uint8 v, bytes32 r, bytes32 s)
    {
        require(sig.length == 65);
        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }
        return (v, r, s);
    }

    function recoverSinger(bytes32 message, bytes memory sig) 
        internal
        pure
        returns (address)
    {
        (uint8 v, bytes32 r, bytes32 s) = splitSignature(sig);
        return ecrecover(message, v, r, s);
    }

    function prefixed(bytes32 hash)
        internal
        pure
        returns (bytes32)
    {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }
}