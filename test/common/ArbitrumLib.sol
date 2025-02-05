// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import {IInterestRateModelV2Factory} from "silo-core-v2/interfaces/IInterestRateModelV2Factory.sol";
import {SiloDeployer} from "silo-core-v2/SiloDeployer.sol";


library ArbitrumLib {
    SiloDeployer constant SILO_DEPLOYER = SiloDeployer(0xB30Ee27f6e19A24Df12dba5Ab4124B6dCE9beeE5);

    address constant CHAINLINK_ETH_USD_AGREGATOR = 0x639Fe6ab55C921f74e7fac1ee960C0B6293ba612;
    address constant CHAINLINK_ETH_USD = 0xed4399235f377AFB48dA005607a0F52Ed7C3bC7F;

    address constant WETH = 0x82aF49447D8a07e3bd95BD0d56f35241523fBab1;
    address constant WETH_WHALE = 0xC3E5607Cd4ca0D5Fe51e09B60Ed97a0Ae6F874dd;

    address constant USDC = 0xaf88d065e77c8cC2239327C5EDb3A432268e5831;
    address constant USDC_WHALE = 0x3931dAb967C3E2dbb492FE12460a66d0fe4cC857;
}
