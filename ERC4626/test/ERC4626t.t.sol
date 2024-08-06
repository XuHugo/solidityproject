// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../../../../../src/token/ERC20/extensions/MockERC4626.sol";
import "./Asset.sol";

contract ERC4626Test2 is Test {
    AssetWithDecimals private _asset = new AssetWithDecimals("Asset", "ASSET", 6);
    MockERC4626 private _erc4626 = new MockERC4626("ERC4626", "ERC4626", _asset);
    address private receiver = address(1);

    function setUp() external {
        _asset.mint(address(this), 100);
    }

    function test_Constructor() external {
        // case 1: asset with uint8 decimal
        assertEq(_erc4626.decimals(), 6);
        assertEq(_erc4626.asset(), address(_asset));

        // case 2: asset with decimal that > type(uint8).max
        AssetWithLargeDecimals _assetWithLargeDecimals = new AssetWithLargeDecimals();
        _erc4626 = new MockERC4626("ERC4626", "ERC4626", IERC20(address(_assetWithLargeDecimals)));
        // default decimals 18 of shares with a large decimal on asset
        assertEq(_erc4626.decimals(), 18);
        assertEq(_erc4626.asset(), address(_assetWithLargeDecimals));

        // case 3: asset without {decimals}
        AssetWithoutDecimals _assetWithoutDecimals = new AssetWithoutDecimals();
        _erc4626 = new MockERC4626("ERC4626", "ERC4626", IERC20(address(_assetWithoutDecimals)));
        // default decimals 18 of shares without decimals() in asset
        assertEq(_erc4626.decimals(), 18);
        assertEq(_erc4626.asset(), address(_assetWithoutDecimals));
    }

    function test_MaxDeposit() external {
        // case 1: asset && shares total supply == 0
        assertEq(_erc4626.totalAssets(), 0);
        assertEq(_erc4626.totalSupply(), 0);
        assertEq(_erc4626.maxDeposit(receiver), type(uint256).max);

        // case 2: asset > 0 && total supply > 0
        _asset.approve(address(_erc4626), 10);
        _erc4626.deposit(10, receiver);
        assertEq(_erc4626.balanceOf(receiver), 10);
        assertEq(_erc4626.totalAssets(), 10);
        assertEq(_erc4626.totalSupply(), 10);
        assertEq(_erc4626.maxDeposit(receiver), type(uint256).max);

        // case 3: asset == 0 && total supply > 0
        _erc4626.transferAsset(receiver, 10);
        console.log(_asset.balanceOf(receiver));
        assertEq(_erc4626.totalAssets(), 0);
        assertEq(_erc4626.totalSupply(), 10);
        assertEq(_erc4626.maxDeposit(receiver), 0);

        // case 4: asset > 0 && total supply == 0
        _erc4626.burn(receiver, 10);
        _asset.transfer(address(_erc4626), 10);
        assertEq(_erc4626.totalAssets(), 10);
        assertEq(_erc4626.totalSupply(), 0);
        assertEq(_erc4626.maxDeposit(receiver), type(uint256).max);
    }

    function test_DepositAndAndPreviewDeposit() external {
        // case 1: asset && shares total supply == 0
        assertEq(_erc4626.totalAssets(), 0);
        assertEq(_erc4626.totalSupply(), 0);
        // deposit 0
        uint assetToDeposit = 0;
        uint sharesToMint = assetToDeposit;
        assertEq(_erc4626.previewDeposit(assetToDeposit), sharesToMint);
        assertEq(_erc4626.deposit(assetToDeposit, receiver), sharesToMint);
        assertEq(_erc4626.totalAssets(), assetToDeposit);
        assertEq(_erc4626.totalSupply(), sharesToMint);
        assertEq(_erc4626.balanceOf(receiver), sharesToMint);
        // deposit some
        assetToDeposit = 20;
        sharesToMint = assetToDeposit;
        assertEq(_erc4626.previewDeposit(assetToDeposit), sharesToMint);
        console.log(sharesToMint);
        _asset.approve(address(_erc4626), assetToDeposit);
        assertEq(_erc4626.deposit(assetToDeposit, receiver), sharesToMint);
        assertEq(_erc4626.totalAssets(), assetToDeposit);
        assertEq(_erc4626.totalSupply(), sharesToMint);
        assertEq(_erc4626.balanceOf(receiver), sharesToMint);

        // case 2: asset > 0 && total supply > 0
        // deposit 0
        assetToDeposit = 0;
        sharesToMint = assetToDeposit;
        assertEq(_erc4626.previewDeposit(assetToDeposit), sharesToMint);
        assertEq(_erc4626.deposit(assetToDeposit, receiver), sharesToMint);
        assertEq(_erc4626.totalAssets(), 20 + assetToDeposit);
        assertEq(_erc4626.totalSupply(), 20 + sharesToMint);
        assertEq(_erc4626.balanceOf(receiver), 20 + sharesToMint);
        // deposit some
        assetToDeposit = 22;
        sharesToMint = assetToDeposit * _erc4626.totalSupply() / _erc4626.totalAssets();
        console.log(sharesToMint);
        assertEq(_erc4626.previewDeposit(assetToDeposit), sharesToMint);
        _asset.approve(address(_erc4626), assetToDeposit);
        assertEq(_erc4626.deposit(assetToDeposit, receiver), sharesToMint);
        assertEq(_erc4626.totalAssets(), 20 + assetToDeposit);
        assertEq(_erc4626.totalSupply(), 20 + sharesToMint);
        assertEq(_erc4626.balanceOf(receiver), 20 + sharesToMint);
        console.log(sharesToMint,_erc4626.totalAssets(), _erc4626.totalSupply());

        // case 3: asset == 0 && total supply > 0
        _erc4626.transferAsset(receiver, 42);
        assertEq(_erc4626.totalAssets(), 0);
        assertEq(_erc4626.totalSupply(), 42);
        // deposit 0
        assetToDeposit = 0;
        sharesToMint = assetToDeposit;
        assertEq(_erc4626.previewDeposit(assetToDeposit), sharesToMint);
        assertEq(_erc4626.deposit(assetToDeposit, receiver), sharesToMint);
        assertEq(_erc4626.totalAssets(), 0 + assetToDeposit);
        assertEq(_erc4626.totalSupply(), 42 + sharesToMint);
        assertEq(_erc4626.balanceOf(receiver), 42 + sharesToMint);
        // deposit some
        // revert for division by 0
        assetToDeposit = 21;
        vm.expectRevert();
        _erc4626.previewDeposit(assetToDeposit);
        vm.expectRevert("ERC4626: deposit more than max");
        _erc4626.deposit(assetToDeposit, receiver);

        // case 4: asset > 0 && total supply == 0
        _asset.transfer(address(_erc4626), 20);
        _erc4626.burn(receiver, 42);
        assertEq(_erc4626.totalAssets(), 20);
        assertEq(_erc4626.totalSupply(), 0);
        // deposit 0
        assetToDeposit = 0;
        sharesToMint = assetToDeposit;
        assertEq(_erc4626.previewDeposit(assetToDeposit), sharesToMint);
        assertEq(_erc4626.deposit(assetToDeposit, receiver), sharesToMint);
        assertEq(_erc4626.totalAssets(), 20 + assetToDeposit);
        assertEq(_erc4626.totalSupply(), 0 + sharesToMint);
        assertEq(_erc4626.balanceOf(receiver), 0 + sharesToMint);
        // deposit some
        assetToDeposit = 15;
        sharesToMint = assetToDeposit;
        assertEq(_erc4626.previewDeposit(assetToDeposit), sharesToMint);
        _asset.approve(address(_erc4626), assetToDeposit);
        assertEq(_erc4626.deposit(assetToDeposit, receiver), sharesToMint);
        assertEq(_erc4626.totalAssets(), 20 + assetToDeposit);
        assertEq(_erc4626.totalSupply(), 0 + sharesToMint);
        assertEq(_erc4626.balanceOf(receiver), 0 + sharesToMint);
        console.log(sharesToMint,_erc4626.totalAssets(), _erc4626.totalSupply());
    }

    function test_MaxMintAndMintAndPreviewMint() external {
        // case 1: total supply == 0
        assertEq(_erc4626.totalSupply(), 0);
        assertEq(_erc4626.maxMint(receiver), type(uint).max);
        // 1 asset 1 share
        uint sharesToMint = 15;
        uint assetToDeposit = sharesToMint;
        assertEq(_erc4626.previewMint(sharesToMint), assetToDeposit);
        _asset.approve(address(_erc4626), assetToDeposit);
        assertEq(_erc4626.mint(sharesToMint, receiver), assetToDeposit);

        assertEq(_erc4626.totalAssets(), 0 + 15);
        assertEq(_erc4626.totalSupply(), 0 + sharesToMint);
        assertEq(_erc4626.balanceOf(receiver), sharesToMint);

        // case 2: total supply != 0
        assertEq(_erc4626.maxMint(receiver), type(uint).max);
        sharesToMint = 10;
        assetToDeposit = sharesToMint * _erc4626.totalAssets() / _erc4626.totalSupply();
        assertEq(_erc4626.previewMint(sharesToMint), assetToDeposit);
        _asset.approve(address(_erc4626), 10);
        assertEq(_erc4626.mint(sharesToMint, receiver), assetToDeposit);
        assertEq(_erc4626.totalAssets(), 15 + assetToDeposit);
        assertEq(_erc4626.totalSupply(), 15 + sharesToMint);
        assertEq(_erc4626.balanceOf(receiver), 15 + sharesToMint);
    }

    function test_MaxWithdraw() external {
        // case 1: total supply == 0
        assertEq(_erc4626.totalSupply(), 0);
        assertEq(_erc4626.maxWithdraw(receiver), 0);

        // case 2: total supply != 0
        _asset.approve(address(_erc4626), 10);
        _erc4626.deposit(10, receiver);
        assertEq(_erc4626.totalSupply(), 10);
        assertEq(
            _erc4626.maxWithdraw(receiver),
            _erc4626.balanceOf(receiver) * _erc4626.totalAssets() / _erc4626.totalSupply()
        );
    }

    function test_WithdrawAndPreviewWithdraw() external {
        // case 1: asset && shares total supply == 0
        // withdraw 0 asset
        uint assetsToWithdraw = 0;
        uint sharesToBurn = assetsToWithdraw;
        assertEq(_erc4626.previewWithdraw(assetsToWithdraw), 0);
        assertEq(_erc4626.withdraw(assetsToWithdraw, receiver, address(this)), sharesToBurn);
        assertEq(_erc4626.totalSupply(), 0);
        assertEq(_erc4626.totalAssets(), 0);
        assertEq(_erc4626.balanceOf(address(this)), 0);
        assertEq(_asset.balanceOf(receiver), 0);
        // withdraw some asset
        assetsToWithdraw = 10;
        assertEq(_erc4626.previewWithdraw(assetsToWithdraw), 10);
        vm.expectRevert("ERC4626: withdraw more than max");
        _erc4626.withdraw(assetsToWithdraw, receiver, address(this));

        // case 2: asset > 0 && total supply > 0
        _asset.approve(address(_erc4626), 20);
        _erc4626.deposit(20, receiver);
        assertEq(_erc4626.totalSupply(), 20);
        assertEq(_erc4626.totalAssets(), 20);
        assertEq(_erc4626.balanceOf(receiver), 20);
        assertEq(_asset.balanceOf(receiver), 0);

        assetsToWithdraw = 10;
        sharesToBurn = assetsToWithdraw * _erc4626.totalSupply() / _erc4626.totalAssets();
        assertEq(_erc4626.previewWithdraw(assetsToWithdraw), sharesToBurn);

        vm.prank(receiver);
        assertEq(_erc4626.withdraw(assetsToWithdraw, receiver, receiver), sharesToBurn);
        assertEq(_erc4626.totalSupply(), 20 - assetsToWithdraw);
        assertEq(_erc4626.totalAssets(), 20 - assetsToWithdraw);
        assertEq(_erc4626.balanceOf(receiver), 20 - sharesToBurn);
        assertEq(_asset.balanceOf(receiver), 0 + assetsToWithdraw);

        // msg.sender is not the owner
        assetsToWithdraw = 2;
        sharesToBurn = assetsToWithdraw * _erc4626.totalSupply() / _erc4626.totalAssets();
        assertEq(_erc4626.previewWithdraw(assetsToWithdraw), sharesToBurn);

        vm.prank(receiver);
        _erc4626.approve(address(this), assetsToWithdraw);
        assertEq(_erc4626.withdraw(assetsToWithdraw, receiver, receiver), sharesToBurn);
        assertEq(_erc4626.totalSupply(), 20 - 10 - assetsToWithdraw);
        assertEq(_erc4626.totalAssets(), 20 - 10 - assetsToWithdraw);
        assertEq(_erc4626.balanceOf(receiver), 20 - 10 - sharesToBurn);
        assertEq(_asset.balanceOf(receiver), 0 + 10 + assetsToWithdraw);

        // revert if withdraw more asset
        assetsToWithdraw = _erc4626.maxWithdraw(receiver) + 1;
        vm.expectRevert("ERC4626: withdraw more than max");
        vm.prank(receiver);
        _erc4626.withdraw(assetsToWithdraw, receiver, receiver);

        // case 3: asset == 0 && total supply > 0
        _erc4626.transferAsset(address(this), _erc4626.totalAssets());
        assertEq(_erc4626.totalAssets(), 0);
        assertEq(_erc4626.totalSupply(), 8);
        assertEq(_erc4626.balanceOf(receiver), 8);
        assertEq(_asset.balanceOf(receiver), 12);
        // revert if without any
        assetsToWithdraw = 1;
        vm.expectRevert();
        _erc4626.previewWithdraw(assetsToWithdraw);
        vm.expectRevert();
        _erc4626.withdraw(assetsToWithdraw, receiver, receiver);

        // case 4: asset > 0 && total supply == 0
        _asset.mint(address(_erc4626), 20);
        _erc4626.burn(receiver, 8);
        assertEq(_erc4626.totalAssets(), 20);
        assertEq(_erc4626.totalSupply(), 0);
        assertEq(_erc4626.balanceOf(receiver), 0);
        assertEq(_asset.balanceOf(receiver), 12);

        assetsToWithdraw = 3;
        sharesToBurn = assetsToWithdraw;
        assertEq(_erc4626.previewWithdraw(assetsToWithdraw), sharesToBurn);

        // revert if withdraw any
        vm.expectRevert("ERC4626: withdraw more than max");
        _erc4626.withdraw(assetsToWithdraw, receiver, receiver);
    }

    function test_MaxRedeemAndRedeemAndPreviewRedeem() external {
        // case 1: total supply == 0
        assertEq(_erc4626.totalSupply(), 0);
        assertEq(_erc4626.maxRedeem(receiver), _erc4626.balanceOf(receiver));
        // 1 asset 1 share
        uint sharesToBurn = 1;
        uint assetToRedeem = sharesToBurn;
        assertEq(_erc4626.previewRedeem(sharesToBurn), assetToRedeem);
        // revert if redeem any
        vm.expectRevert("ERC4626: redeem more than max");
        vm.prank(receiver);
        _erc4626.redeem(sharesToBurn, receiver, receiver);

        // case 2: total supply != 0
        _asset.approve(address(_erc4626), 50);
        _erc4626.deposit(50, receiver);
        assertEq(_erc4626.totalAssets(), 50);
        assertEq(_erc4626.totalSupply(), 50);
        assertEq(_erc4626.balanceOf(receiver), 50);
        assertEq(_asset.balanceOf(receiver), 0);

        assertEq(_erc4626.maxRedeem(receiver), _erc4626.balanceOf(receiver));
        sharesToBurn = 20;
        assetToRedeem = sharesToBurn * _erc4626.totalAssets() / _erc4626.totalSupply();
        assertEq(_erc4626.previewRedeem(sharesToBurn), assetToRedeem);

        vm.prank(receiver);
        assertEq(_erc4626.redeem(sharesToBurn, receiver, receiver), assetToRedeem);
        assertEq(_erc4626.totalAssets(), 50 - assetToRedeem);
        assertEq(_erc4626.totalSupply(), 50 - sharesToBurn);
        assertEq(_erc4626.balanceOf(receiver), 50 - sharesToBurn);
        assertEq(_asset.balanceOf(receiver), assetToRedeem);

        // revert if redeem more
        sharesToBurn = _erc4626.maxRedeem(receiver) + 1;
        vm.expectRevert("ERC4626: redeem more than max");
        _erc4626.redeem(sharesToBurn, receiver, receiver);
    }

    function test_AssetAndTotalAssetsAndConvertToSharesAndConvertToAssets() external {
        // test {asset}
        assertEq(_erc4626.asset(), address(_asset));

        // total supply == 0
        // test {convertToShares}
        assertEq(_erc4626.totalSupply(), 0);
        for (uint assets = 0; assets < 100; ++assets) {
            assertEq(_erc4626.convertToShares(assets), assets);
        }
        // test {convertToAssets}
        for (uint shares = 0; shares < 100; ++shares) {
            assertEq(_erc4626.convertToAssets(shares), shares);

        }

        // total supply != 0
        _asset.approve(address(_erc4626), 50);
        _erc4626.deposit(50, receiver);
        assertEq(_erc4626.totalSupply(), 50);
        // test {totalAssets}
        assertEq(_erc4626.totalAssets(), 50);
        // test {convertToShares}
        for (uint assets = 1; assets < 100; ++assets) {
            assertEq(_erc4626.convertToShares(assets), assets * _erc4626.totalSupply() / _erc4626.totalAssets());
        }
        // test {convertToAssets}
        for (uint shares = 1; shares < 100; ++shares) {
            assertEq(_erc4626.convertToAssets(shares), shares * _erc4626.totalAssets() / _erc4626.totalSupply());
        }
    }
}