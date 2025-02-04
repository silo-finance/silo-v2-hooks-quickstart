// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import {IERC20} from "openzeppelin5/token/ERC20/IERC20.sol";
import {Clones} from "openzeppelin5/proxy/Clones.sol";

import {ISiloConfig} from "silo-core-v2/interfaces/ISiloConfig.sol";
import {ISilo} from "silo-core-v2/interfaces/ISilo.sol";
import {IShareToken, IERC20Metadata} from "silo-core-v2/interfaces/IShareToken.sol";
import {IGaugeHookReceiver} from "silo-core-v2/interfaces/IGaugeHookReceiver.sol";
import {ShareTokenLib} from "silo-core-v2/lib/ShareTokenLib.sol";

import {CollectedErrors} from "../contracts/errors/CollectedErrors.sol";
import {OZErrors} from "../contracts/errors/OZErrors.sol";

import {NonBorrowableHook} from "../contracts/NonBorrowableHook.sol";
import {Labels} from "./common/Labels.sol";

/*
forge test -vv --mc NonBorrowableHookTest
*/
contract NonBorrowableHookTest is Labels {
    /// @dev see: gitmodules/silo-contracts-v2/silo-core/contracts/lib/ShareTokenLib.sol
    /// keccak256(abi.encode(uint256(keccak256("silo.storage.ShareToken")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant _STORAGE_LOCATION = 0x01b0b3f9d6e360167e522fa2b18ba597ad7b2b35841fec7e1ca4dbb0adea1200;

    ISiloConfig public siloConfig;

    NonBorrowableHook public clonedHook;

    function setUp() public {
        uint256 blockToFork = 6512598;
        vm.createSelectFork(vm.envString("RPC_SONIC"), blockToFork);

        siloConfig = ISiloConfig(0x062A36Bbe0306c2Fd7aecdf25843291fBAB96AD2);

        _setLabels(siloConfig);
    }

    /// can I switch collateral?
    /// can I transfer debt after select same silo

    /*
    forge test -vv --mt test_nonBorrowableHook_sameAsset
    */
    function test_nonBorrowableHook_sameAsset() public {
        address user = makeAddr("user");
        (address silo0, address silo1) = siloConfig.getSilos();

        uint256 depositAmount = 20;

        vm.startPrank(silo0);
        IERC20(ISilo(silo0).asset()).transfer(user, depositAmount);
        vm.stopPrank();


        vm.startPrank(user);
        IERC20(ISilo(silo0).asset()).approve(silo0, depositAmount);
        ISilo(silo0).deposit(depositAmount, user);

        ISilo(silo0).borrowSameAsset(1, user, user);

        // user was able to borrow, but with non borrowable hook can't:

        _deployHookAndMockItForSilo(silo0);

        vm.expectRevert(NonBorrowableHook.NonBorrowableHook_CanNotBorrowThisAsset.selector);
        ISilo(silo0).borrowSameAsset(1, user, user);

        vm.stopPrank();
    }

    function _deployHookAndMockItForSilo(address _silo) public {
        /// @dev by default initialization of hook is disable by constructor,
        /// so the only way to use hook is to clone it based on implementation
        clonedHook = NonBorrowableHook(Clones.clone(address(new NonBorrowableHook())));
        vm.label(address(clonedHook), "clonedHook");

        // NOTICE: do not use encodePacked
        clonedHook.initialize(siloConfig, abi.encode(address(1), ISilo(_silo).asset()));

        _mockHookAddress(_silo);

        ISilo(_silo).updateHooks();
    }

    function _mockHookAddress(address _silo) internal {
        ISiloConfig.ConfigData memory config = siloConfig.getConfig(_silo);
        config.hookReceiver = address(clonedHook);

        vm.mockCall(
            address(siloConfig),
            abi.encodeWithSelector(ISiloConfig.getConfig.selector, _silo),
            abi.encode(config)
        );

        _mockHookSetupStorage(_silo);
    }

    function _mockHookSetupStorage(address _silo) internal {
        uint256 storageSlot = uint256(_STORAGE_LOCATION) + 2;
        vm.store(_silo, bytes32(storageSlot), bytes32(uint256(uint160(address(clonedHook)))));
        emit log_named_address("changing storage for silo, for hookReceiver", address(clonedHook));
    }
}
