// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

// All collected custom errors
/* This file is generated automatically */

error SomeError();
error SiloFixtureHookReceiverImplNotFound(string hookReceiver);
error ActionsStopped();
error ShareTokenBeforeForbidden();
error UnknownAction();
error UnknownBorrowAction();
error UnknownShareTokenAction();
error UnknownSwitchCollateralAction();
error SenderNotSolventAfterTransfer();
error SenderNotSolventAfterTransfer();
error CustomError1(uint256 a, uint256 b);
error UnsupportedNetworkForDeploy(string networkAlias);
error ConfigNotFound();
error DeployedContractNotFound(string contractName);
error OwnerNotFound();
error SiloNotFound();
error IncentivizedAssetNotFound();
error IncentivizedAssetMismatch();
error NotHookReceiverOwner();
error InvalidShareToken();
error EthTransferFailed();
error InvalidInputLength();
error OnlyNotifier();
error TooLongProgramName();
error InvalidIncentivesProgramName();
error OnlyNotifierOrOwner();
error InvalidDistributionEnd();
error InvalidConfiguration();
error IndexOverflowAtEmissionsPerSecond();
error InvalidToAddress();
error InvalidUserAddress();
error ClaimerUnauthorized();
error InvalidRewardToken();
error IncentivesProgramAlreadyExists();
error IncentivesProgramNotFound();
error DifferentRewardsTokens();
error EmptyRecipient();
error AddressZero();
error KeyIsTaken();
error EmptyCoordinates();
error NoDebtToCover();
error STokenNotSupported();
error MaxDebtToCoverZero();
error UserSolvent();
error AddressZero();
error FeeOverflow();
error FlashLoanNotPossible();
error TokenIsNotAContract();
error FailedToParseBoolean();
error MissingHookReceiver();
error ZeroAddress();
error DaoFeeReceiverZeroAddress();
error EmptyToken0();
error EmptyToken1();
error MaxFeeExceeded();
error InvalidFeeRange();
error SameAsset();
error SameRange();
error InvalidIrm();
error InvalidMaxLtv();
error InvalidLt();
error InvalidDeployer();
error DaoMinRangeExceeded();
error DaoMaxRangeExceeded();
error MaxDeployerFeeExceeded();
error MaxFlashloanFeeExceeded();
error MaxLiquidationFeeExceeded();
error InvalidCallBeforeQuote();
error OracleMisconfiguration();
error InvalidQuoteToken();
error HookIsZeroAddress();
error LiquidationTargetLtvTooHigh();
error EmptyShareToken();
error UnexpectedCollateralToken();
error UnexpectedDebtToken();
error NoDebtToCover();
error FullLiquidationRequired();
error UserIsSolvent();
error UnknownRatio();
error NoRepayAssets();
error AddressZero();
error DeployConfigFirst();
error AlreadyInitialized();
error InvalidBeta();
error InvalidKcrit();
error InvalidKi();
error InvalidKlin();
error InvalidKlow();
error InvalidTcrit();
error InvalidTimestamps();
error InvalidUcrit();
error InvalidUlow();
error InvalidUopt();
error InvalidRi();
error EmptySiloConfig();
error AlreadyConfigured();
error UnableToRepayFlashloan();
error FailedToCreateAnOracle(address _factory);
error HookReceiverMisconfigured();
error OwnerIsZeroAddress();
error InvalidShareToken();
error WrongGaugeShareToken();
error CantRemoveActiveGauge();
error EmptyGaugeAddress();
error RequestNotSupported();
error GaugeIsNotConfigured();
error GaugeAlreadyConfigured();
error OnlySilo();
error OnlySiloOrTokenOrHookReceiver();
error WrongSilo();
error OnlyDebtShareToken();
error DebtExistInOtherSilo();
error FeeTooHigh();
error CrossReentrantCall();
error CrossReentrancyNotActive();
error OnlySilo();
error OnlySiloConfig();
error OwnerIsZero();
error RecipientIsZero();
error AmountExceedsAllowance();
error RecipientNotSolventAfterTransfer();
error SenderNotSolventAfterTransfer();
error ZeroTransfer();
error UnsupportedFlashloanToken();
error FlashloanAmountTooBig();
error NothingToWithdraw();
error NotEnoughLiquidity();
error NotSolvent();
error BorrowNotPossible();
error EarnedZero();
error FlashloanFailed();
error AboveMaxLtv();
error SiloInitialized();
error OnlyHookReceiver();
error NoLiquidity();
error InputCanBeAssetsOrShares();
error CollateralSiloAlreadySet();
error RepayTooHigh();
error ZeroAmount();
error InputZeroShares();
error ReturnZeroAssets();
error ReturnZeroShares();
