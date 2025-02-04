// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import {console2} from "forge-std/console2.sol";

import {IHookReceiver} from "silo-core-v2/interfaces/IHookReceiver.sol";
import {ISiloConfig} from "silo-core-v2/interfaces/ISiloConfig.sol";
import {ISilo} from "silo-core-v2/interfaces/ISilo.sol";

import {Hook} from "silo-core-v2/lib/Hook.sol";
import {BaseHookReceiver} from "silo-core-v2/utils/hook-receivers/_common/BaseHookReceiver.sol";
import {GaugeHookReceiver} from "silo-core-v2/utils/hook-receivers/gauge/GaugeHookReceiver.sol";
import {PartialLiquidation} from "silo-core-v2/utils/hook-receivers/liquidation/PartialLiquidation.sol";

contract NonBorrowableHook is GaugeHookReceiver, PartialLiquidation {
    error NonBorrowableHook_CanNotBorrowThisAsset();
    error NonBorrowableHook_WrongAssetForMarket();
    error NonBorrowableHook_AssetZero();

    address public nonBorrowableSilo;

    /// @dev this method is mandatory and it has to initialize inherited contracts
    function initialize(ISiloConfig _siloConfig, bytes calldata _data) external initializer override {
        // do not remove initialization lines, if you want fully compatible functionality

        // --begin of initialization--
        (address owner, address nonBorrowableAsset) = abi.decode(_data, (address, address));

        // initialize hook with SiloConfig address.
        // SiloConfig is the source of all information about Silo markets you are extending.
        BaseHookReceiver.__BaseHookReceiver_init(_siloConfig);

        // initialize GaugeHookReceiver. Owner can set "gauge" aka incentives contract for a Silo retroactively.
        GaugeHookReceiver.__GaugeHookReceiver_init(owner);
        // --end of initialization--

        require(nonBorrowableAsset != address(0), NonBorrowableHook_AssetZero());

        (address silo0, address silo1) = _siloConfig.getSilos();

        if (ISilo(silo0).asset() == nonBorrowableAsset) nonBorrowableSilo = silo0;
        else if (ISilo(silo1).asset() == nonBorrowableAsset) nonBorrowableSilo = silo1;
        else revert NonBorrowableHook_WrongAssetForMarket();
    }

    function hookReceiverConfig(address _silo)
        external
        view
        override (BaseHookReceiver, IHookReceiver)
        returns (uint24 hooksBefore, uint24 hooksAfter)
    {
        // do not remove this line if you want fully compatible functionality
        (hooksBefore, hooksAfter) = _hookReceiverConfig(_silo);

        // your code here
        hooksBefore = uint24(Hook.addAction(hooksBefore, Hook.BORROW | Hook.BORROW_SAME_ASSET));
    }

    /// @inheritdoc IHookReceiver
    function beforeAction(address _silo, uint256 _action, bytes calldata) external {
        if (
            !Hook.matchAction(_action, Hook.BORROW) &&
            !Hook.matchAction(_action, Hook.BORROW_SAME_ASSET)
        ) {
            // Silo does not use it, replace revert with your code if you want to use before hook
            revert RequestNotSupported();
        }

        require(_silo != nonBorrowableSilo, NonBorrowableHook_CanNotBorrowThisAsset());
    }
}
