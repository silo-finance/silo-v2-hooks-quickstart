// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import {IERC20} from "openzeppelin5/token/ERC20/IERC20.sol";
import {Clones} from "openzeppelin5/proxy/Clones.sol";

import {ISiloConfig} from "silo-core-v2/interfaces/ISiloConfig.sol";
import {ISilo} from "silo-core-v2/interfaces/ISilo.sol";
import {IShareToken, IERC20Metadata} from "silo-core-v2/interfaces/IShareToken.sol";
import {IGaugeHookReceiver} from "silo-core-v2/interfaces/IGaugeHookReceiver.sol";
import {ISiloDeployer} from "silo-core-v2/interfaces/ISiloDeployer.sol";
import {IInterestRateModelV2} from "silo-core-v2/interfaces/IInterestRateModelV2.sol";

import {ShareTokenLib} from "silo-core-v2/lib/ShareTokenLib.sol";
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

        clonedHook = NonBorrowableHook(Clones.clone(address(new NonBorrowableHook())));
        siloConfig = deployer.deploySilo(ArbitrumLib.SILO_DEPLOYER, address(clonedHook));

        // NOTICE: do not use encodePacked
        clonedHook.initialize(siloConfig, abi.encode(address(this), ArbitrumLib.USDC));

        _setLabels(siloConfig);
    }

    /*
    forge test --mt test_nonBorrowableHook_twoAssets -vv
    */
    function test_nonBorrowableHook_USDC() public {
        address user = makeAddr("user");
        (address wethSilo, address usdcSilo) = siloConfig.getSilos();

        uint256 depositAmount = 1e18;

        vm.startPrank(ArbitrumLib.WETH_WHALE);
        IERC20(ISilo(wethSilo).asset()).transfer(user, depositAmount);
        vm.stopPrank();

        vm.startPrank(user);
        IERC20(ISilo(wethSilo).asset()).approve(wethSilo, depositAmount);
        ISilo(wethSilo).deposit(depositAmount, user);

        vm.expectRevert(NonBorrowableHook.NonBorrowableHook_CanNotBorrowThisAsset.selector);
        ISilo(usdcSilo).borrow(1, user, user);

        vm.stopPrank();
    }

    /*
    forge test --mt test_nonBorrowableHook_twoAssets -vv
    */
    function test_nonBorrowableHook_WETH() public {
        address user = makeAddr("user");
        (address wethSilo, address usdcSilo) = siloConfig.getSilos();

        uint256 depositAmount = 1e18;

        vm.startPrank(ArbitrumLib.USDC_WHALE);
        IERC20(ISilo(usdcSilo).asset()).transfer(user, depositAmount);
        vm.stopPrank();

        vm.startPrank(user);
        IERC20(ISilo(usdcSilo).asset()).approve(usdcSilo, depositAmount);
        ISilo(usdcSilo).deposit(depositAmount, user);

        ISilo(wethSilo).borrow(1, user, user);

        vm.stopPrank();
    }

    /*
    forge test --mt test_nonBorrowableHook_sameAsset -vv
    */
    function test_nonBorrowableHook_sameAsset0() public {
        address user = makeAddr("user");
        (address silo0,) = siloConfig.getSilos();

        vm.startPrank(ArbitrumLib.WETH_WHALE);
        IERC20(ISilo(silo0).asset()).transfer(user, 1e18);
        vm.stopPrank();

        _nonBorrowableHook_sameAsset(silo0);
    }

    function test_nonBorrowableHook_sameAsset1() public {
        address user = makeAddr("user");
        (, address silo1) = siloConfig.getSilos();

        vm.startPrank(ArbitrumLib.USDC_WHALE);
        IERC20(ISilo(silo1).asset()).transfer(user, 1e6);
        vm.stopPrank();

        _nonBorrowableHook_sameAsset(silo1);
    }

    function _nonBorrowableHook_sameAsset(address _silo) public {
        address user = makeAddr("user");

        uint256 depositAmount = IERC20(ISilo(_silo).asset()).balanceOf(user);

        vm.startPrank(user);
        IERC20(ISilo(_silo).asset()).approve(_silo, depositAmount);
        ISilo(_silo).deposit(depositAmount, user);

        ISilo(_silo).borrowSameAsset(1, user, user);

        vm.stopPrank();
    }
}
