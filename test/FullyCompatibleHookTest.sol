// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import {Test} from "forge-std/Test.sol";

import {IGaugeHookReceiver} from "silo-core-v2/interfaces/IGaugeHookReceiver.sol";

import {FullyCompatibleHook} from "../contracts/FullyCompatibleHook.sol";

/*
forge test -vv --mc FullyCompatibleHookTest
*/
contract FullyCompatibleHookTest is Test {
    FullyCompatibleHook public hook;

    function setUp() public {
        hook = new FullyCompatibleHook();
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