// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import {Test} from "forge-std/Test.sol";

import {ISiloConfig} from "silo-core-v2/interfaces/ISiloConfig.sol";
import {ISilo} from "silo-core-v2/interfaces/ISilo.sol";
import {IERC20Metadata} from "silo-core-v2/interfaces/IShareToken.sol";
import {IGaugeHookReceiver} from "silo-core-v2/interfaces/IGaugeHookReceiver.sol";

import {CollectedErrors} from "../contracts/CollectedErrors.sol";
import {OZErrors} from "../contracts/OZErrors.sol";

import {NonBorrowableHook} from "../contracts/NonBorrowableHook.sol";

/*
forge test -vv --mc NonBorrowableHookTest
*/
contract NonBorrowableHookTest is Test {
    ISiloConfig public siloConfig;

    NonBorrowableHook public hook;

    function setUp() public {
        uint256 blockToFork = 6512598;
        vm.createSelectFork(vm.envString("RPC_SONIC"), blockToFork);

        siloConfig = ISiloConfig(0x062A36Bbe0306c2Fd7aecdf25843291fBAB96AD2);
        hook = new NonBorrowableHook();

        _setLabels();
    }

    /*
    forge test -vv --mt test_nonBorrowableHook_sameAsset
    */
    function test_nonBorrowableHook_sameAsset() public {
        address user = makeAddr("user");
        (address silo0, address silo1) = siloConfig.getSilos();


        ISilo(silo0).borrowSameAsset(1, user, user);

        // hook is design to be clonable, constructor disabled initialization
//        vm.expectRevert(Initializable.InvalidInitialization.selector);
//        hook.initialize(ISiloConfig(address(0)), "");
    }

    function _mockHookAddress() public {
        // siloConfig.
    }

    function _setLabels() internal virtual {
        (address silo0, address silo1) = siloConfig.getSilos();
        ISiloConfig.ConfigData memory config = siloConfig.getConfig(silo0);

        _labels(silo0, "0");
        _labels(silo1, "1");
    }

    function _labels(address _silo, string memory _i) internal virtual {
        ISiloConfig.ConfigData memory config = siloConfig.getConfig(_silo);

        vm.label(config.silo, string.concat("silo", _i));
        vm.label(config.hookReceiver, string.concat("hookReceiver", _i));
        vm.label(config.collateralShareToken, string.concat("collateralShareToken", _i));
        vm.label(config.protectedShareToken, string.concat("protectedShareToken", _i));
        vm.label(config.debtShareToken, string.concat("debtShareToken", _i));
        vm.label(config.interestRateModel, string.concat("interestRateModel", _i));
        vm.label(config.maxLtvOracle, string.concat("maxLtvOracle", _i));
        vm.label(config.solvencyOracle, string.concat("solvencyOracle", _i));
        vm.label(config.token, string.concat(IERC20Metadata(config.token).symbol(), _i));
    }
}
