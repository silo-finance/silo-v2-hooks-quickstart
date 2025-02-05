// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import {Test} from "forge-std/Test.sol";

import {IERC20Metadata} from "silo-core-v2/interfaces/IShareToken.sol";

import {ISiloConfig} from "silo-core-v2/interfaces/ISiloConfig.sol";
import {ISilo} from "silo-core-v2/interfaces/ISilo.sol";
import {ArbitrumLib} from "./ArbitrumLib.sol";

contract Labels is Test {
    function _setLabels(ISiloConfig _siloConfig) internal virtual {
        vm.label(address(ArbitrumLib.SILO_DEPLOYER), "SILO_DEPLOYER");
        vm.label(address(ArbitrumLib.CHAINLINK_ETH_USD_AGREGATOR), "CHAINLINK_ETH_USD_AGREGATOR");
        vm.label(address(ArbitrumLib.WETH), "WETH");
        vm.label(address(ArbitrumLib.USDC), "USDC");

        vm.label(address(_siloConfig), string.concat("siloConfig"));

        (address silo0, address silo1) = _siloConfig.getSilos();

        _labels(_siloConfig, silo0, "0");
        _labels(_siloConfig, silo1, "1");
    }

    function _labels(ISiloConfig _siloConfig, address _silo, string memory _i) internal virtual {
        ISiloConfig.ConfigData memory config = _siloConfig.getConfig(_silo);

        vm.label(config.silo, string.concat("collateralShareToken/silo", _i));
        vm.label(config.hookReceiver, string.concat("hookReceiver", _i));
        vm.label(config.protectedShareToken, string.concat("protectedShareToken", _i));
        vm.label(config.debtShareToken, string.concat("debtShareToken", _i));
        vm.label(config.interestRateModel, string.concat("interestRateModel", _i));
        vm.label(config.maxLtvOracle, string.concat("maxLtvOracle", _i));
        vm.label(config.solvencyOracle, string.concat("solvencyOracle", _i));
        vm.label(config.token, string.concat(IERC20Metadata(config.token).symbol(), _i));
    }
}
