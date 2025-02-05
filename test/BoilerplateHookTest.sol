// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import {Test} from "forge-std/Test.sol";

import {Initializable} from "openzeppelin5/proxy/utils/Initializable.sol";

import {ISiloConfig} from "silo-core-v2/interfaces/ISiloConfig.sol";
import {IGaugeHookReceiver} from "silo-core-v2/interfaces/IGaugeHookReceiver.sol";

import {BoilerplateHook} from "../contracts/BoilerplateHook.sol";

/*
forge test -vv --mc BoilerplateHookTest
*/
contract BoilerplateHookTest is Test {
    BoilerplateHook public hook;

    function setUp() public {
        hook = new BoilerplateHook();
    }

    function test_initialize_once() public {
        // hook is design to be clonable, constructor disabled initialization
        vm.expectRevert(Initializable.InvalidInitialization.selector);
        hook.initialize(ISiloConfig(address(0)), "");
    }

    function test_hookReceiverConfig() public {
        (uint24 hooksBefore, uint24 hooksAfter) = hook.hookReceiverConfig(address(0));
        assertEq(hooksBefore, 0, "hook before is empty by default");
        assertEq(hooksBefore, 0, "hook after is empty by default");
    }

    function test_beforeAction_revertsByDefault() public {
        vm.expectRevert(IGaugeHookReceiver.RequestNotSupported.selector);
        hook.beforeAction(address(0), 0, "");
    }

    function test_afterAction_revertsByDefault() public {
        vm.expectRevert(IGaugeHookReceiver.GaugeIsNotConfigured.selector);
        hook.afterAction(address(0), 0, "");
    }
}
