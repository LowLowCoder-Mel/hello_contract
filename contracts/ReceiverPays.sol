// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

// 接收支付合约
contract ReciverPays {
    address owner = msg.sender;

    mapping(uint => bool) usedNonces;

    constructor() public payable {}

    function claimPayment(
        uint amount,
        uint nonce,
        bytes memory signature
    )
        public
    {
        require(!usedNonces[nonce]);
        usedNonces[nonce] = true;
        bytes32 message = prefix(keccak256(abi.encodePacked(amount, nonce, signature, this)));
        require(recoverSinger(message, signature) == owner);
        msg.sender.transfer(amount);
    }

    function splitSignatrue(bytes memory sig)
        internal
        pure
        returns(uint8 v, bytes32 r, bytes32 s) 
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
        (uint8 v, bytes32 r, bytes32 s) = splitSignatrue(sig);
        return ecrecover(message, v, r, s);
    }

    function prefix(bytes32 _hash)
        internal
        pure
        returns (bytes32)
    {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", _hash));
    }
}