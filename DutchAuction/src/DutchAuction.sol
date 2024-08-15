// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/interfaces/IERC721.sol";

contract DutchAuction is Ownable {
    IERC721 public immutable nft;
    address public immutable seller;
    uint256 private constant AUCTIONTIME = 10 minutes; // acution time

    uint256 public immutable startPrice; // max price
    uint256 public immutable endPrice; // min price

    uint256 public immutable dropInterval; // how long will change price
    uint256 public immutable dropStep; //

    uint256 public auctionStartTime; //
    uint256 public id; //NFT id

    // constructor
    constructor(
        uint256 _startPrice,
        uint256 _endPrice,
        uint256 _dropInterval,
        address _nft,
        uint256 _id,
        address _seller
    ) Ownable(msg.sender) {
        require(
            _startPrice > _endPrice,
            "start price must bigger than end price!"
        );
        startPrice = _startPrice;
        endPrice = _endPrice;
        nft = IERC721(_nft);
        auctionStartTime = block.timestamp;
        id = _id;
        seller = _seller;
        dropInterval = _dropInterval;
        dropStep = (_startPrice - _endPrice) / (AUCTIONTIME / _dropInterval);
    }

    // acution fun
    function auction() external payable {
        uint256 _saleStartTime = uint256(auctionStartTime); // new local varible, save gas
        require(
            _saleStartTime != 0 && block.timestamp >= _saleStartTime,
            "sale has not started yet"
        ); // check auction time, if staring

        uint256 price = getPrice(); // calc price
        require(msg.value >= price, "Need to send more ETH.."); // check balances

        // fransfer NFT
        //nft._mint(msg.sender, id);
        nft.safeTransferFrom(seller, msg.sender, id);

        //  refund eth
        if (msg.value > price) {
            payable(msg.sender).transfer(msg.value - price); //catch reentry
        }
        payable(seller).transfer(price);
    }

    // get current price
    function getPrice() public view returns (uint256) {
        if (block.timestamp < auctionStartTime) {
            return startPrice;
        } else if (block.timestamp - auctionStartTime >= AUCTIONTIME) {
            return endPrice;
        } else {
            uint256 steps = (block.timestamp - auctionStartTime) / dropInterval;
            return startPrice - (steps * dropStep);
        }
    }

    // withdrwa，only Owner can call
    function withdrawMoney() external onlyOwner {
        (bool success, ) = msg.sender.call{value: address(this).balance}("");
        require(success, "Transfer failed.");
    }
}
