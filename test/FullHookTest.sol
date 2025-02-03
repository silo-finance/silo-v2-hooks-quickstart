// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import "forge-std/Test.sol"; // Import Foundry's Test library
import "../contracts/FullHook.sol";       // Adjust the import path depending on the location of contract A

/*
FOUNDRY_PROFILE=core-test
forge test -vv --mc ATest
*/
contract FullHookTest is Test {
    FullHook public contractA;

    function setUp() public {
        // Deploy the contract before each test
        contractA = new FullHook();
    }

    function test_AFunction() public {
        // Call the `a` function and check that it returns true
        (uint24 hooksBefore, uint24 hooksAfter) = contractA.hookReceiverConfig(address(0));
        assertEq(hooksBefore, 0, "Function a should return true");
    }
}