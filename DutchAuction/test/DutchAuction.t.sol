// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.21;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {DutchAuction} from "../src/DutchAuction.sol";

contract DutchAuctionTest is Test {
    DutchAuction public dauction;
    NFT public nft;
    address sellr = vm.addr(1);
    address bob = vm.addr(2);
    uint256 blockTime;

    function setUp() public {
        nft = new NFT();
        dauction = new DutchAuction(
            100 ether,
            10 ether,
            1 minutes,
            address(nft),
            1,
            sellr
        );
        //check blocktime
        blockTime = dauction.auctionStartTime();
        console.log("blockTime:", blockTime);
        //set 1 of nft of owner
        nft.mint(sellr, 1);
        vm.prank(sellr);
        nft.approve(address(dauction), 1);
    }

    function test_getPrice() public {
        //set blocktime
        vm.warp(121);
        uint256 price = dauction.getPrice();
        assertEq(price, 82 ether);
    }

    function test_auction() public {
        vm.deal(bob, 100 ether);
        //set blocktime
        vm.warp(121);
        vm.prank(bob);
        dauction.auction{value: 90 ether}();
        assertEq(sellr.balance, 82 ether);
        assertEq(nft.ownerOf(1), address(bob));
    }
}

contract NFT is ERC721 {
    constructor() ERC721("DA", "DA") {}

    function mint(address to, uint256 tokenId) public {
        _mint(to, tokenId);
    }
}
