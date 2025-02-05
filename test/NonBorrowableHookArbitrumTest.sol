// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import {IERC20} from "openzeppelin5/token/ERC20/IERC20.sol";

import {ISiloConfig} from "silo-core-v2/interfaces/ISiloConfig.sol";
import {ISilo} from "silo-core-v2/interfaces/ISilo.sol";
import {IShareToken, IERC20Metadata} from "silo-core-v2/interfaces/IShareToken.sol";

import {SiloDeployer} from "silo-core-v2/SiloDeployer.sol";

import {CollectedErrors} from "../contracts/errors/CollectedErrors.sol";
import {OZErrors} from "../contracts/errors/OZErrors.sol";

import {NonBorrowableHook} from "../contracts/NonBorrowableHook.sol";
import {Labels} from "./common/Labels.sol";
import {DeploySilo} from "./common/DeploySilo.sol";
import {ArbitrumLib} from "./common/ArbitrumLib.sol";

/*
forge test --mc NonBorrowableHookArbitrumTest -vv
*/
contract NonBorrowableHookArbitrumTest is Labels {
    ISiloConfig public siloConfig;

    NonBorrowableHook public clonedHook;

    function setUp() public {
        uint256 blockToFork = 302603188;
        vm.createSelectFork(vm.envString("RPC_ARBITRUM"), blockToFork);

        DeploySilo deployer = new DeploySilo();

        siloConfig = deployer.deploySilo(
            ArbitrumLib.SILO_DEPLOYER,
            address(new NonBorrowableHook()),
            // NOTICE: do not use encodePacked, as the hook will not be able to decode this data with abi.decode
            abi.encode(address(this), ArbitrumLib.USDC)
        );

        clonedHook = NonBorrowableHook(_getHookAddress(siloConfig));

        _setLabels(siloConfig);
    }

    /*
    forge test --mt test_nonBorrowableHook_borrowUSDC -vv
    */
    function test_nonBorrowableHook_borrowUSDC() public {
        address depositor = makeAddr("depositor");
        address borrower = makeAddr("borrower");
        (address wethSilo, address usdcSilo) = siloConfig.getSilos();

        // deposit liquidity
        _getUSDC(depositor, 1e6);
        _deposit(usdcSilo, depositor, 1e6);

        // add collateral
        _getWETH(borrower, 1e18);
        _deposit(wethSilo, borrower, 1e18);

        vm.expectRevert(NonBorrowableHook.NonBorrowableHook_CanNotBorrowThisAsset.selector);
        vm.prank(borrower);
        ISilo(usdcSilo).borrow(1, borrower, borrower);
    }

    /*
    forge test --mt test_nonBorrowableHook_borrowWETH -vv
    */
    function test_nonBorrowableHook_borrowWETH() public {
        address depositor = makeAddr("depositor");
        address borrower = makeAddr("borrower");
        (address wethSilo, address usdcSilo) = siloConfig.getSilos();

        // deposit liquidity
        _getWETH(depositor, 1e18);
        _deposit(wethSilo, depositor, 1e18);

        // add collateral
        _getUSDC(borrower, 1e6);
        _deposit(usdcSilo, borrower, 1e6);

        vm.prank(borrower);
        ISilo(wethSilo).borrow(1e10, borrower, borrower);
    }

    /*
    forge test --mt test_nonBorrowableHook_sameAsset -vv
    */
    function test_nonBorrowableHook_sameAsset0() public {
        address user = makeAddr("user");
        (address silo0,) = siloConfig.getSilos();

        _getWETH(user, 1e18);

        _nonBorrowableHook_sameAsset(silo0);
    }

    function test_nonBorrowableHook_sameAsset1() public {
        address user = makeAddr("user");
        (, address silo1) = siloConfig.getSilos();

        _getUSDC(user, 1e6);

        _nonBorrowableHook_sameAsset(silo1);
    }

    function _nonBorrowableHook_sameAsset(address _silo) public {
        address user = makeAddr("user");

        uint256 depositAmount = IERC20(ISilo(_silo).asset()).balanceOf(user);

        _deposit(_silo, user, depositAmount);

        vm.prank(user);
        ISilo(_silo).borrowSameAsset(1, user, user);
    }

    function _getUSDC(address _user, uint256 _amount) internal {
        vm.prank(ArbitrumLib.USDC_WHALE);
        IERC20(ArbitrumLib.USDC).transfer(_user, _amount);
    }

    function _getWETH(address _user, uint256 _amount) internal {
        vm.prank(ArbitrumLib.WETH_WHALE);
        IERC20(ArbitrumLib.WETH).transfer(_user, _amount);
    }

    function _deposit(address _silo, address _user, uint256 _amount) internal {
        vm.startPrank(_user);
        IERC20(ISilo(_silo).asset()).approve(_silo, _amount);
        ISilo(_silo).deposit(_amount, _user);
        vm.stopPrank();
    }

    function _getHookAddress(ISiloConfig _siloConfig) internal view returns (address hook) {
        (address silo, ) = _siloConfig.getSilos();

        hook = _siloConfig.getConfig(silo).hookReceiver;
    }
}
