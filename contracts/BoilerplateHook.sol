// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import {IHookReceiver} from "silo-core-v2/interfaces/IHookReceiver.sol";
import {ISiloConfig} from "silo-core-v2/interfaces/ISiloConfig.sol";
import {BaseHookReceiver} from "silo-core-v2/utils/hook-receivers/_common/BaseHookReceiver.sol";
import {GaugeHookReceiver} from "silo-core-v2/utils/hook-receivers/gauge/GaugeHookReceiver.sol";
import {PartialLiquidation} from "silo-core-v2/utils/hook-receivers/liquidation/PartialLiquidation.sol";

/// @title Boilerplate hook for developers
/// @dev
/// `GaugeHookReceiver` - is a hook that allows to set incentives for a Silo market retroactively
/// `PartialLiquidation` - implements partial liquidation logic for the Silo market
///     !!! If `PartialLiquidation` is removed Silo will not have liquidation functionality. !!!
/// Developers can remove or replace any of the inherited contracts or add new ones.
/// It is important to understand that the hooks in the Silo protocol are very flexible/powerful
/// and can be combined in any way. These two hooks are a good example of how developers can use hooks
/// to implement custom logic. As the `GaugeHookReceiver` is designed to receive notifications from the Silo protocol,
/// while `PartialLiquidation` do not receive any notifications, but is using hook to extend Silo functionality
/// with partial liquidation logic. So, you, as a developer, can receive notifications before/after each action
/// in the Silo (this is what we do in the GaugeHookReceiver), which opens the possibility to execute a custom logic
/// whenever users interact with the Silo market, or you can extend Silo with a new functionality creating new methods
/// via your custom hook (this is what we do in the PartialLiquidation).
contract BoilerplateHook is GaugeHookReceiver, PartialLiquidation {
    /// @dev this method is mandatory and it has to initialize inherited contracts
    /// @inheritdoc IHookReceiver
    function initialize(ISiloConfig _siloConfig, bytes calldata _data) external initializer override {
        // do not remove initialization lines, if you want fully compatible functionality

        // --begin of initialization--
        (address owner) = abi.decode(_data, (address));

        // initialize hook with SiloConfig address.
        // SiloConfig is the source of all information about Silo markets you are extending.
        BaseHookReceiver.__BaseHookReceiver_init(_siloConfig);

        // initialize GaugeHookReceiver. Owner can set "gauge" aka incentives contract for a Silo retroactively.
        GaugeHookReceiver.__GaugeHookReceiver_init(owner);
        // --end of initialization--


        // put your code here, that will be executed on hook initialization
    }

    /// @inheritdoc IHookReceiver
    function hookReceiverConfig(address _silo)
        external
        view
        override (BaseHookReceiver, IHookReceiver)
        returns (uint24 hooksBefore, uint24 hooksAfter)
    {
        // do not remove this line if you want fully compatible functionality
        (hooksBefore, hooksAfter) = _hookReceiverConfig(_silo);

        // your code here
        // you can remove this method if you are not using it in your hook
    }

    /// @inheritdoc IHookReceiver
    function beforeAction(address, uint256, bytes calldata) external pure {
        // Silo does not use it, replace revert with your code if you want to use before hook
        revert RequestNotSupported();

        // you can remove this method if you are not using it in your hook
    }

    /// @inheritdoc IHookReceiver
    function afterAction(address _silo, uint256 _action, bytes calldata _inputAndOutput)
        public
        override(GaugeHookReceiver, IHookReceiver)
    {
        // do not remove this line if you want fully compatible functionality
        GaugeHookReceiver.afterAction(_silo, _action, _inputAndOutput);

        // your code here
        // you can remove this method if you are not using it in your hook
    }
}
