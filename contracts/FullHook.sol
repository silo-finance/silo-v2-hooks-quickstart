// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import {IHookReceiver} from "silo-core-v2/interfaces/IHookReceiver.sol";
import {ISiloConfig} from "silo-core-v2/interfaces/ISiloConfig.sol";
import {GaugeHookReceiver} from "silo-core-v2/utils/hook-receivers/gauge/GaugeHookReceiver.sol";
// import {PartialLiquidation} from "silo-v2/core/utils/hook-receivers/liquidation/PartialLiquidation.sol";

contract FullHook is GaugeHookReceiver {
    function initialize(ISiloConfig _siloConfig, bytes calldata _data) external override {
        GaugeHookReceiver.initialize(_siloConfig, _data);

        // put here your code that will be executed on hook initialization
    }

    function hookReceiverConfig(address _silo) external view returns (uint24 hooksBefore, uint24 hooksAfter) {
        (hooksBefore, hooksAfter) = _hookReceiverConfig(_silo);

    }

    /// @notice state of Silo before action, can be also without interest, if you need them, call silo.accrueInterest()
    function beforeAction(address _silo, uint256 _action, bytes calldata _input) external override {
        GaugeHookReceiver.beforeAction(_silo, _action, _input);

    }

    function afterAction(address _silo, uint256 _action, bytes calldata _inputAndOutput) external override {
        GaugeHookReceiver.afterAction(_silo, _action, _inputAndOutput);

    }
}
