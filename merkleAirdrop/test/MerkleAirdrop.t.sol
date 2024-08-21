// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "forge-std/Test.sol";
import {stdJson} from "forge-std/StdJson.sol";
import "../src/MerkleAirdrop.sol";
import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract MerkleAirdropTest is Test {
    using stdJson for string;

    struct Proof {
        address account;
        uint amount;
        bytes32[] proof;
    }

    string private _jsonTree = vm.readFile("test/data/tree.json");
    string private _jsonRoot = vm.readFile("test/data/root.json");
    string private _jsonProofs = vm.readFile("test/data/proofs.json");
    bytes32 private _rootHash = _jsonRoot.readBytes32(".root");
    MerkleAirdrop private _testing;
    Airdrop private airdrop;
    MockToken private token;

    function setUp() public {
        _testing = new MerkleAirdrop(_rootHash);
        token = new MockToken("test", "TEST");
        airdrop = new Airdrop(address(token), _rootHash);
    }

    function test_verify() external {
        Proof[] memory proofs = abi.decode(_jsonProofs.parseRaw(""), (Proof[]));
        for (uint i = 0; i < proofs.length; ++i) {
            assertTrue(
                _testing.verify(
                    proofs[i].proof,
                    proofs[i].account,
                    proofs[i].amount
                )
            );
        }
    }

    function test_claim() external {
        Proof[] memory proofs = abi.decode(vm.parseJson(_jsonProofs), (Proof[]));
        for (uint i = 0; i < proofs.length; ++i) {
            vm.expectEmit();
            emit Airdrop.Claim(proofs[i].account, proofs[i].amount);
            airdrop.claim(
                proofs[i].proof,
                proofs[i].account,
                proofs[i].amount
            );
            assertEq(token.balanceOf(proofs[i].account), proofs[i].amount);    
        }
    }
}

contract Airdrop is MerkleAirdrop{
    event Claim(address to, uint256 amount);

    MockIToken public token;

    constructor(address _token, bytes32 _root) MerkleAirdrop(_root){
        token = MockIToken(_token);
    }

    function claim(bytes32[] memory proof, address account, uint256 amount)
        external returns (bool)
    {
        verify(proof, account, amount);

        token.mint(account, amount);

        emit Claim(account, amount);
    }
}

interface MockIToken {
    function mint(address to, uint256 amount) external;
}

contract MockToken is ERC20 {
    constructor(string memory name, string memory symbol)
    ERC20(name, symbol) {}

    function mint(address account, uint amount) external {
        _mint(account, amount);
    }
}
