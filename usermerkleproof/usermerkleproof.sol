// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract UserMerkleProof {
    bytes32[] public hashes;

    constructor(string memory name, string memory age,string memory sex,string memory race) {

        hashes.push(keccak256(abi.encodePacked(name)));
        hashes.push(keccak256(abi.encodePacked(age)));
        hashes.push(keccak256(abi.encodePacked(sex)));
        hashes.push(keccak256(abi.encodePacked(race)));

        uint n = 4;
        uint offset = 0;

        while (n > 0) {
            for (uint i = 0; i < n - 1; i += 2) {
                hashes.push(
                    keccak256(
                        abi.encodePacked(hashes[offset + i], hashes[offset + i + 1])
                    )
                );
            }
            offset += n;
            n = n / 2;
        }
    }

    function verify(
        bytes32[] memory proof,
        bytes32 root,
        string memory leaf,
        uint index
    ) public pure returns (bool) {
        bytes32 hash = keccak256(abi.encodePacked(leaf));

        for (uint i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];

            if (index % 2 == 0) {
                hash = keccak256(abi.encodePacked(hash, proofElement));
            } else {
                hash = keccak256(abi.encodePacked(proofElement, hash));
            }

            index = index / 2;
        }

        return hash == root;
    }

    function genProof(
        uint index
    ) public view returns (bytes32[] memory) {
        require(4 > index,"error index!");

        bytes32[] memory proof = new bytes32[](2);

        uint n = 4;
        uint i = 0;
        uint j = index;
        uint offset = 0;

        while (n > 0) {
            if (offset == 6){
                break;
            }
            if (j % 2 == 0) {
                proof[i] = hashes[j + offset + 1];
            } else {
                proof[i] = hashes[j + offset - 1];
            }
            offset += n;
            j = j / 2;
            n = n / 2;
            i = i + 1;
        }

        return proof;
    }

    function getRoot() public view returns (bytes32) {
        return hashes[hashes.length - 1];
    }
}