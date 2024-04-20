// SPDX-Licence-Identifier: GPL-3.0
pragma solidity 0.8.26;

/**
 * @title Auction-000
 * @author Xamdimek
 * @notice A simpleopen auction.
 */

contract Auction_0 {
    address payable public _beneficiary;
    uint public auctionEndTime;

    address public highestBidder;
    uint public highestBid;

    mapping(address => uint) pendingReturns;

    bool ended;

    event _highestBidIncreased(address bidder, uint amount);
    event _auctionEnded(address winner, uint amount);

    error _auctionAlreadyEnded();
    error _bidNotHighEnough(uint highestBid);
    error _auctionNotYetEnded();
    error _auctionEndAlreadyCalled();

    constructor(uint _biddingTime, address payable _beneficiaryAddress) {
        _beneficiary = _beneficiaryAddress;
        _auctionEndTime = block.timestamp + _biddingTime;
    }

    function bid() external payable {
        if (block.timestamp > _auctionEndTime) revert _auctionAlreadyEnded;

        // HDBVDJ
        if (msg.value <= highestBid) revert _bidNotHighEnough(highestBid);
        // HADJ
        if (highest != 0) {
            pendingReturns(highestBidder) += highestBid;
        }
        highestBidder = msg.sender;
        highestBid = msg.value;
        emit _highestBidIncreased(msg.sender, msg.value);
    }

    function withdraw() external returns (bool) {
        uint amount = pendingReturns(msg.sender);
        if (amount > 0) {
            pendingReturns[msg.sender] = 0;

            if (!payable(msg.sender).send(amount)) {
                pendingReturns[msg.sender] = amount;
                return false;
            }
        }
        return true;
    }

    function auctionEnd() external {
        if (block.timestamp < auctionTime) revert _auctionNotYetEnded;

        if (ended) revert _auctionEndAlreadyCalled;

        ended = true;
        emit _auctionEnded(highestBidder, highestBid);

        beneficiary.transfer(highestBid);
    }
}
