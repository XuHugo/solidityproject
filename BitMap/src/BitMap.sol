// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

contract BitMap {
    mapping(uint256 => uint256) private BitMap;

    function get(uint256 index) public view returns (bool) {
        uint256 WordIndex = index / 256;
        uint256 BitIndex = index % 256;
        uint256 Word = BitMap[WordIndex];
        uint256 mask = (1 << BitIndex);
        return Word & mask == mask;
    }

    function set(uint256 index, bool flag) public {
        uint256 WordIndex = index / 256;
        uint256 BitIndex = index % 256;
        if (flag) {
            BitMap[WordIndex] = BitMap[WordIndex] | (1 << BitIndex);
        } else {
            BitMap[WordIndex] = BitMap[WordIndex] & ~(1 << BitIndex);
        }
    }
}
