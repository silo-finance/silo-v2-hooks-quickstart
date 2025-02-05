// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import {IERC20Metadata} from "openzeppelin5/token/ERC20/extensions/IERC20Metadata.sol";

import {ISiloConfig} from "silo-core-v2/interfaces/ISiloConfig.sol";
import {ISiloDeployer} from "silo-core-v2/interfaces/ISiloDeployer.sol";
import {IInterestRateModelV2} from "silo-core-v2/interfaces/IInterestRateModelV2.sol";

import {ChainlinkV3OracleFactory} from "silo-oracles-v2/chainlinkV3/ChainlinkV3OracleFactory.sol";
import {IChainlinkV3Oracle, AggregatorV3Interface} from "silo-oracles-v2/interfaces/IChainlinkV3Oracle.sol";
import {SiloDeployer} from "silo-core-v2/SiloDeployer.sol";

import {ArbitrumLib} from "./ArbitrumLib.sol";

contract DeploySilo {
    function deploySilo(
        SiloDeployer _siloDeployer,
        address _hookImplementation,
        bytes memory _hookInitializationData
    ) external returns (ISiloConfig siloConfig) {
        ISiloDeployer.ClonableHookReceiver memory _clonableHookReceiver = ISiloDeployer.ClonableHookReceiver({
            implementation: _hookImplementation,
            initializationData: _hookInitializationData
        });

        siloConfig = _siloDeployer.deploy({
            _oracles: _oracles(),
            _irmConfigData0: _irmConfigData(),
            _irmConfigData1: _irmConfigData(),
            _clonableHookReceiver: _clonableHookReceiver,
            _siloInitData: _siloInitData()
        });
    }

    function _oracles() internal returns (ISiloDeployer.Oracles memory oracles) {
        // Silo has two options to set oracles: for maxLTV and solvency
        // if you want to set the same for both, set for solvency, it will be copied for maxLTV as well
        // if you set only for maxLtvOracle it will throw error.
        // if you already have oracles deployed, you can set it directly in _irmConfigData() and ignore this setup
        oracles.solvencyOracle0.factory = address(new ChainlinkV3OracleFactory());

        IChainlinkV3Oracle.ChainlinkV3DeploymentConfig memory config;
        config.baseToken = IERC20Metadata(ArbitrumLib.WETH);
        config.quoteToken = IERC20Metadata(ArbitrumLib.USDC);
        config.primaryAggregator = AggregatorV3Interface(ArbitrumLib.CHAINLINK_ETH_USD_AGREGATOR);
        config.primaryHeartbeat = 87001;
        // this will normalize price to be in 6 decimals, so same decimals as quote asset (USDC)
        config.normalizationDivider = 1e20;

        oracles.solvencyOracle0.txInput = abi.encodeWithSelector(ChainlinkV3OracleFactory.create.selector, config);
    }

    function _irmConfigData() internal pure returns (IInterestRateModelV2.Config memory irmConfigData) {
        irmConfigData.uopt = 900000000000000001;
        irmConfigData.ucrit = 900000000000000002;
        irmConfigData.ulow = 900000000000000000;
        irmConfigData.kcrit = 7927447996;
        irmConfigData.klow = 1937820621;
        irmConfigData.beta = 11574074074074;
        irmConfigData.ri = 1744038559;
    }

    function _siloInitData() internal view returns (ISiloConfig.InitData memory siloInitData) {
        siloInitData.deployer = msg.sender;
        siloInitData.deployerFee = 0;
        siloInitData.daoFee = 0.1e18;

        siloInitData.token0 = ArbitrumLib.WETH;
        siloInitData.maxLtv0 = 0.75e18;
        siloInitData.lt0 = 0.80e18;
        siloInitData.liquidationTargetLtv0 = 0.78e18;
        siloInitData.liquidationFee0 = 0.075e18;

        siloInitData.token1 = ArbitrumLib.USDC;
        siloInitData.maxLtv1 = 0.75e18;
        siloInitData.lt1 = 0.80e18;
        siloInitData.liquidationTargetLtv0 = 0.78e18;
        siloInitData.liquidationFee0 = 0.075e18;
    }
}
