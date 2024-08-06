// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract AssetWithDecimals is ERC20 {
    uint8 private _decimals;

    constructor(
        string memory name,
        string memory symbol,
        uint8 dec
    )
    ERC20(name, symbol){
        _decimals = dec;
    }

    function decimals() public view override returns (uint8){
        return _decimals;
    }

    function mint(address account, uint amount) external {
        _mint(account, amount);
    }
}

contract AssetWithLargeDecimals {
    function decimals() public pure returns (uint){
        return type(uint8).max + 1;
    }
}

contract AssetWithoutDecimals {}
