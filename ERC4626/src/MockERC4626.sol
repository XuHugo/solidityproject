// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "openzeppelin-contracts/contracts/token/ERC20/extensions/ERC4626.sol";

contract MockERC4626 is ERC4626 {
    constructor(
        string memory name,
        string memory symbol,
        IERC20 asset
    )
    ERC4626(asset)
    ERC20(name, symbol)
    {}

    function burn(address account, uint amount) external {
        _burn(account, amount);
    }

    function transferAsset(address account, uint amount) external {
        IERC20(asset()).transfer(account, amount);
    }
}
