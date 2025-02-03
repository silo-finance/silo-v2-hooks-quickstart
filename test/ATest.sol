// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import "forge-std/Test.sol"; // Import Foundry's Test library
import "../contracts/A.sol";       // Adjust the import path depending on the location of contract A

/*
FOUNDRY_PROFILE=core-test
forge test -vv --mc ATest
*/
contract ATest is Test {
    A public contractA;

    function setUp() public {
        // Deploy the contract before each test
        contractA = new A();
    }

    function test_AFunction() public {
        // Call the `a` function and check that it returns true
        bool result = contractA.a();
        assertTrue(result, "Function a should return true");
    }
}