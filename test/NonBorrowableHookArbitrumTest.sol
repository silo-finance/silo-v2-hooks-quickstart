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

    function _setUp() public {
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
    forge test --mt test_nonBorrowableHook -vv
    */
    function test_nonBorrowableHook() public {
        _setUp();

        address user = makeAddr("user");
        (address silo0, address silo1) = siloConfig.getSilos();

        uint256 depositAmount = 1e18;

        vm.startPrank(silo0);
        IERC20(ISilo(silo0).asset()).transfer(user, depositAmount);
        vm.stopPrank();

        vm.startPrank(user);
        IERC20(ISilo(silo0).asset()).approve(silo0, depositAmount);
        ISilo(silo0).deposit(depositAmount, user);

        ISilo(silo1).borrow(1, user, user);

        // user was able to borrow, but with non borrowable hook can't:

        vm.expectRevert(NonBorrowableHook.NonBorrowableHook_CanNotBorrowThisAsset.selector);
        ISilo(silo1).borrow(1, user, user);

        vm.stopPrank();
    }
}
