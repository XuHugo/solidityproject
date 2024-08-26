// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "forge-std/Test.sol";
import "../src/BitMap.sol";

contract BitMapTest is Test {
    BitMap bitmap;

    function setUp() public {
        bitmap = new BitMap();
        bitmap.set(8, true);
        bitmap.set(256 + 8, true);
        bitmap.set(256 + 256 + 8, true);
    }

    function testGet() public {
        assertEq(bitmap.get(8), true);
        assertEq(bitmap.get(80), false);
        assertEq(bitmap.get(256 + 8), true);
        assertEq(bitmap.get(256 + 256 + 8), true);
    }

    function testSet() public {
        bitmap.set(256 + 256 + 256 + 256 + 8, true);
        assertEq(bitmap.get(256 + 256 + 256 + 256 + 8), true);
    }
}
