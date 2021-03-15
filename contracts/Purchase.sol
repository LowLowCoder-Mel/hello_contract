// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

// 采购合约
contract Purchase {
    uint public value;
    address payable public seller;
    address payable public buyer;

    enum State { Created, Locked, Release, Inactive }
    State public state;

    modifier condition(bool _condition) {
        require(_condition);
        _;
    }

    modifier onlyBuyer() {
        require(
            buyer == msg.sender,
            "Only buyer can call this."
        );
        _;
    }

    modifier onlySeller() {
        require(
            msg.sender == seller,
            "Only seller can call this."
        );
        _;
    }

    modifier inState(State _state) {
        require(
            state == _state,
            "Invalid State"
        );
        _;
    }

    event Aborded();
    event PurchaseConfirmed();
    event ItemReceived();
    event SellerRefunded();

    constructor() public payable {
        seller = msg.sender;
        value = msg.value / 2;
        require((2 * value) == msg.value, "Value has to be even.");
    }

    function abort() public onlySeller inState(State.Created) {
        emit Aborded();
        state = State.Inactive;
        seller.transfer(address(this).balance);
    }

    function confirmPurchase()
        public
        inState(State.Created)
        condition(msg.value == (2 * value)) 
        payable
    {
        emit PurchaseConfirmed();
        buyer = msg.sender;
        state = State.Locked;
    }

    function confirmReceived() 
        public
        inState(State.Locked)
        onlyBuyer
    {
        emit ItemReceived();
        state = State.Release;
        buyer.transfer(value);
    }

    function refundSeller()
        public
        onlySeller
        inState(State.Release)
    {
        emit SellerRefunded();
        state = State.Inactive;
        seller.transfer(3 * value);
    }
}