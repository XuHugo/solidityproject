// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "openzeppelin-contracts/contracts/utils/cryptography/MerkleProof.sol";

contract MerkleAirdrop {
    using MerkleProof for bytes32[];
    bytes32 private _root;

    constructor(bytes32 root) {
        _root = root;
    }

    function verify(
        bytes32[] memory proof,
        address account,
        uint amount
    ) external view returns (bool) {
        bytes32 leaf = keccak256(
            bytes.concat(keccak256(abi.encode(account, amount)))
        );
        return proof.verify(_root, leaf);
    }

    function verifyCalldata(
        bytes32[] calldata proof,
        address account,
        uint amount
    ) external view returns (bool) {
        bytes32 leaf = keccak256(
            bytes.concat(keccak256(abi.encode(account, amount)))
        );
        return proof.verifyCalldata(_root, leaf);
    }

    function processProof(
        bytes32[] memory proof,
        bytes32 leaf
    ) external pure returns (bytes32) {
        return proof.processProof(leaf);
    }

    function processProofCalldata(
        bytes32[] calldata proof,
        bytes32 leaf
    ) external pure returns (bytes32) {
        return proof.processProofCalldata(leaf);
    }
}
