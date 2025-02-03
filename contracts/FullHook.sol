// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import {IHookReceiver} from "silo-core-v2/interfaces/IHookReceiver.sol";
import {ISiloConfig} from "silo-core-v2/interfaces/ISiloConfig.sol";
import {BaseHookReceiver} from "silo-core-v2/utils/hook-receivers/_common/BaseHookReceiver.sol";
import {GaugeHookReceiver} from "silo-core-v2/utils/hook-receivers/gauge/GaugeHookReceiver.sol";
// import {PartialLiquidation} from "silo-v2/core/utils/hook-receivers/liquidation/PartialLiquidation.sol";

contract FullHook is GaugeHookReceiver {
    function initialize(ISiloConfig _siloConfig, bytes calldata _data) external override {
//  TODO      super.initialize(_siloConfig, _data);

        // put here your code that will be executed on hook initialization
    }

    function hookReceiverConfig(address _silo)
        external
        view
        override (BaseHookReceiver, IHookReceiver)
        returns (uint24 hooksBefore, uint24 hooksAfter)
    {
        (hooksBefore, hooksAfter) = _hookReceiverConfig(_silo);

        // code
    }

    /// @inheritdoc IHookReceiver
    function beforeAction(address, uint256, bytes calldata)
        external
    {
        // Silo does not use it.
        revert RequestNotSupported();
    }

    function afterAction(address _silo, uint256 _action, bytes calldata _inputAndOutput) public override {
        super.afterAction(_silo, _action, _inputAndOutput);

    }
}
