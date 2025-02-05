// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import {console} from "forge-std/console.sol";


import {IERC20Metadata} from "openzeppelin5/token/ERC20/extensions/IERC20Metadata.sol";

import {ISiloConfig} from "silo-core-v2/interfaces/ISiloConfig.sol";
import {ISiloDeployer} from "silo-core-v2/interfaces/ISiloDeployer.sol";
import {IInterestRateModelV2} from "silo-core-v2/interfaces/IInterestRateModelV2.sol";
import {IInterestRateModelV2Factory} from "silo-core-v2/interfaces/IInterestRateModelV2Factory.sol";

import {ChainlinkV3OracleFactory} from "silo-oracles-v2/chainlinkV3/ChainlinkV3OracleFactory.sol";
import {IChainlinkV3Oracle, AggregatorV3Interface} from "silo-oracles-v2/interfaces/IChainlinkV3Oracle.sol";
import {SiloDeployer} from "silo-core-v2/SiloDeployer.sol";
import {SiloFactory} from "silo-core-v2/SiloFactory.sol";

import {ArbitrumLib} from "./ArbitrumLib.sol";

contract DeploySilo {
    /// @dev chainlink oracle on arbitrum

//    function deploySilo(
//        SiloDeployer _siloDeployer,
//        address _hook
//    ) public returns (ISiloConfig siloConfig) {
//        SiloFactory factory = new SiloFactory(address(this));
//
//        factory.createSilo(
//            _siloInitData(),
//            siloConfig,
//            SILO_IMPL,
//            SHARE_PROTECTED_COLLATERAL_TOKEN_IMPL,
//            SHARE_DEBT_TOKEN_IMPL
//        );
//        // initialize hook receiver only if it was cloned
//        _initializeHookReceiver(_siloInitData, siloConfig, _clonableHookReceiver);
//
//
//        // this is empty because deploying hook is handeled manually and final address is pass as argument
//        ISiloDeployer.ClonableHookReceiver memory _clonableHookReceiver;
//
//        siloConfig = _siloDeployer.deploy({
//            _oracles: _oracles(),
//            _irmConfigData0: _irmConfigData(),
//            _irmConfigData1: _irmConfigData(),
//            _clonableHookReceiver: _clonableHookReceiver,
//            _siloInitData: _siloInitData(_hook)
//        });
//
//        console.log("_siloDeployer.deploy end");
//    }

    function deploySilo(
        SiloDeployer _siloDeployer,
        address _hook
    ) public returns (ISiloConfig siloConfig) {
        // this is empty because deploying hook is handeled manually and final address is pass as argument
        ISiloDeployer.ClonableHookReceiver memory _clonableHookReceiver;

        siloConfig = _siloDeployer.deploy({
            _oracles: _oracles(),
            _irmConfigData0: _irmConfigData(),
            _irmConfigData1: _irmConfigData(),
            _clonableHookReceiver: _clonableHookReceiver,
            _siloInitData: _siloInitData(_hook)
        });

        console.log("_siloDeployer.deploy end");
    }

    function _oracles() internal returns (ISiloDeployer.Oracles memory oracles) {
        // Silo has two options to set oracles: for max LTV and solvency
        // if you want to set the same for both, set for solvency, it will be copied for maxLTV as well
        // if you set only for maxLtvOracle it will throw error
        oracles.solvencyOracle1.factory = address(new ChainlinkV3OracleFactory());

        IChainlinkV3Oracle.ChainlinkV3DeploymentConfig memory config;
        config.baseToken = IERC20Metadata(ArbitrumLib.WETH);
        config.quoteToken = IERC20Metadata(ArbitrumLib.USDC);
        config.primaryAggregator = AggregatorV3Interface(ArbitrumLib.CHAINLINK_ETH_USD_AGREGATOR);
        config.primaryHeartbeat = 87001;
        config.normalizationMultiplier = 1e10;

        oracles.solvencyOracle1.txInput = abi.encodeWithSelector(ChainlinkV3OracleFactory.create.selector, config);

        console.log("_oracles setup end");
    }

    function _irmConfigData() internal returns (IInterestRateModelV2.Config memory irmConfigData) {
        irmConfigData.uopt = 900000000000000001;
        irmConfigData.ucrit = 900000000000000002;
        irmConfigData.ulow = 900000000000000000;
        irmConfigData.kcrit = 7927447996;
        irmConfigData.klow = 1937820621;
        irmConfigData.beta = 11574074074074;
        irmConfigData.ri = 1744038559;

        console.log("_irmConfigData() end");
    }

    function _siloInitData(address _hookReceiver) internal returns (ISiloConfig.InitData memory siloInitData) {
        siloInitData.deployer = msg.sender;
        siloInitData.hookReceiver = _hookReceiver;
        siloInitData.deployerFee = 0;
        siloInitData.daoFee = 0.1e18;

        siloInitData.token0 = ArbitrumLib.WETH;
        //
        siloInitData.solvencyOracle0;
        (, IInterestRateModelV2 irm) = ArbitrumLib.INTEREST_RATE_MODEL_FACTORY.create(_irmConfigData());

        siloInitData.interestRateModel0 = address(irm);
        siloInitData.maxLtv0 = 0.75e18;
        siloInitData.lt0 = 0.80e18;
        siloInitData.liquidationTargetLtv0 = 0.78e18;
        siloInitData.liquidationFee0 = 0.075e18;

        siloInitData.token1 = ArbitrumLib.USDC;
        //
//        siloInitData.solvencyOracle1 = address(123);

        (, irm) = ArbitrumLib.INTEREST_RATE_MODEL_FACTORY.create(_irmConfigData());

        siloInitData.interestRateModel1 = address(irm);
        siloInitData.maxLtv1 = 0.75e18;
        siloInitData.lt1 = 0.80e18;
        siloInitData.liquidationTargetLtv0 = 0.78e18;
        siloInitData.liquidationFee0 = 0.075e18;

        console.log("_siloInitData() end");
    }
}
