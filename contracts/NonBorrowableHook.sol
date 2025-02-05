// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import {IHookReceiver} from "silo-core-v2/interfaces/IHookReceiver.sol";
import {ISiloConfig} from "silo-core-v2/interfaces/ISiloConfig.sol";
import {ISilo} from "silo-core-v2/interfaces/ISilo.sol";

import {Hook} from "silo-core-v2/lib/Hook.sol";
import {BaseHookReceiver} from "silo-core-v2/utils/hook-receivers/_common/BaseHookReceiver.sol";
import {GaugeHookReceiver} from "silo-core-v2/utils/hook-receivers/gauge/GaugeHookReceiver.sol";
import {PartialLiquidation} from "silo-core-v2/utils/hook-receivers/liquidation/PartialLiquidation.sol";

/// @dev Example of hook, that prevents borrowing asset. Note: borrowing same asset is still available.
contract NonBorrowableHook is GaugeHookReceiver, PartialLiquidation {
    error NonBorrowableHook_CanNotBorrowThisAsset();
    error NonBorrowableHook_WrongAssetForMarket();
    error NonBorrowableHook_AssetZero();

    address public nonBorrowableSilo;

    /// @dev this method is mandatory and it has to initialize inherited contracts
    function initialize(ISiloConfig _siloConfig, bytes calldata _data) external initializer override {
        // do not remove initialization lines, if you want fully compatible functionality
        (address owner, address nonBorrowableAsset) = abi.decode(_data, (address, address));

        // initialize hook with SiloConfig address.
        // SiloConfig is the source of all information about Silo markets you are extending.
        BaseHookReceiver.__BaseHookReceiver_init(_siloConfig);

        // initialize GaugeHookReceiver. Owner can set "gauge" aka incentives contract for a Silo retroactively.
        GaugeHookReceiver.__GaugeHookReceiver_init(owner);

        __NonBorrowableHook_init(_siloConfig, nonBorrowableAsset);
    }

    function __NonBorrowableHook_init(ISiloConfig _siloConfig, address _nonBorrowableAsset) internal {
        require(_nonBorrowableAsset != address(0), NonBorrowableHook_AssetZero());

        (address silo0, address silo1) = _siloConfig.getSilos();
        address nonBorrowableSiloCached;

        if (ISilo(silo0).asset() == _nonBorrowableAsset)
            nonBorrowableSiloCached = silo0;
        else if (ISilo(silo1).asset() == _nonBorrowableAsset)
            nonBorrowableSiloCached = silo1;
        else
            revert NonBorrowableHook_WrongAssetForMarket();

        nonBorrowableSilo = nonBorrowableSiloCached;

        // fetch current setup in case there were some hooks already implemented
        (uint256 hooksBefore, uint256 hooksAfter) = _hookReceiverConfig(nonBorrowableSiloCached);

        // your code here
        //
        // It is recommended to use `addAction` and `removeAction` when working with hook.
        // It is expected that hooks bitmap will store settings for multiple hooks and utility
        // functions like `addAction` and `removeAction` will make sure to not override
        // other hooks' settings.
        hooksBefore = Hook.addAction(hooksBefore, Hook.BORROW);
        _setHookConfig(nonBorrowableSiloCached, hooksBefore, hooksAfter);
    }

    /// @inheritdoc IHookReceiver
    function beforeAction(address _silo, uint256 _action, bytes calldata) external view {
        if (Hook.matchAction(_action, Hook.BORROW)) {
            require(_silo != nonBorrowableSilo, NonBorrowableHook_CanNotBorrowThisAsset());
        }

        
    }
}
