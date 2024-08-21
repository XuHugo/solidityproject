// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "forge-std/Test.sol";
import "../src/MerkleAirdrop.sol";

contract MerkleAirdropTest is Test {
    using stdJson for string;

    struct Acc {
        address account;
        uint amount;
    }

    struct Proof {
        Acc account;
        bytes32[] proof;
    }

    string private _jsonTree = vm.readFile("test/data/tree.json");
    string private _jsonRoot = vm.readFile("test/data/root.json");
    string private _jsonProofs = vm.readFile("test/data/proofs.json");
    bytes32 private _rootHash = _jsonRoot.readBytes32("root");
    MerkleAirdrop private _testing = new MerkleAirdrop(_rootHash);

    function test_verify() external {
        console.log("root:", _jsonRoot);
        Proof[] memory proofs = abi.decode(_jsonProofs.parseRaw(""), (Proof[]));
        for (uint i = 0; i < proofs.length; ++i) {
            //assertTrue(
            //    _testing.verify(
            //        proofs[i].proof,
            //        proofs[i].account,
            //        proofs[i].amount
            //    )
            //);
            console.log("proofs:", i);
        }
    }
}
