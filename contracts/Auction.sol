// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

// 简单的拍卖合约
contract SimpleAution {
    address payable public beneficiary;
    uint public autionEndTime;

    address public highestBidder;
    uint public highestBid;

    mapping(address => uint) pendingReturns;

    bool ended;

    event HighestBidIncreased(address bidder, uint amount);
    event AutionEnded(address winner, uint amount);

    constructor(
        uint _biddingTime,
        address payable _beneficiary
    ) public {
        beneficiary = _beneficiary;
        autionEndTime = now + _biddingTime;
    }

    function bid() payable public {
        require(
            now <= autionEndTime,
            "Auction Already End" 
        );
        require(
            msg.value > highestBid,
            "There already is higher bid"
        );
        if (highestBid != 0) {
            pendingReturns[highestBidder] += highestBid;
        }
        highestBidder = msg.sender;
        highestBid = msg.value;
        emit HighestBidIncreased(msg.sender, msg.value);
    }

    function withdraw() public returns (bool) {
        uint amount = pendingReturns[msg.sender];
        if (amount > 0) {
            // 清零很重要, 防止在接收到回执之前再次调用
            pendingReturns[msg.sender] = 0;
            if (!msg.sender.send(amount)) {
                pendingReturns[msg.sender] = amount;
                return false;
            }
        }
        return true;
    }

    function auctionEnd() public {
        require(
            now >= autionEndTime,
            "auction not yet end"
        );
        require(
            !ended,
            "auction has already been end"
        );
        ended = true;
        emit AutionEnded(highestBidder, highestBid);
    }
}