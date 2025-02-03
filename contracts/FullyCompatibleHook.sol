// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import {IHookReceiver} from "silo-core-v2/interfaces/IHookReceiver.sol";
import {ISiloConfig} from "silo-core-v2/interfaces/ISiloConfig.sol";
import {BaseHookReceiver} from "silo-core-v2/utils/hook-receivers/_common/BaseHookReceiver.sol";
import {GaugeHookReceiver} from "silo-core-v2/utils/hook-receivers/gauge/GaugeHookReceiver.sol";
import {PartialLiquidation} from "silo-core-v2/utils/hook-receivers/liquidation/PartialLiquidation.sol";

contract FullyCompatibleHook is GaugeHookReceiver, PartialLiquidation {
    function initialize(ISiloConfig _siloConfig, bytes calldata _data) external override {
        // do not remove this line if you want fully compatible functionality
        _init(_siloConfig, _data);

        // put your code here, that will be executed on hook initialization
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
    }

    /// @inheritdoc IHookReceiver
    function beforeAction(address, uint256, bytes calldata) external {
        // Silo does not use it, replace revert with your code if you want to use before hook
        revert RequestNotSupported();
    }

    /// @inheritdoc IHookReceiver
    function afterAction(address _silo, uint256 _action, bytes calldata _inputAndOutput)
        public override(GaugeHookReceiver, IHookReceiver)
    {
        // do not remove this line if you want fully compatible functionality
        GaugeHookReceiver.afterAction(_silo, _action, _inputAndOutput);

        // your code here
    }

    function _init(ISiloConfig _siloConfig, bytes calldata _data) internal {
        (address owner) = abi.decode(_data, (address));

        BaseHookReceiver.__BaseHookReceiver_init(_siloConfig);
        GaugeHookReceiver.__GaugeHookReceiver_init(owner);
    }
}
