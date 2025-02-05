## 1. Configuring hooks
Hooks configuration is done in the hook contract. The way how it is done is the choice of the developer.
Let's take a look at the `GaugeHookReceiver` implementation where we configure the hooks for the share token transfer.
`GaugeHookReceiver` is designed to send notifications to the gauge (or Silo incentives controller) when the share token is transferred.

### Example of configuring hooks in the `GaugeHookReceiver`

```solidity
// We use `Hook` library for uint256 to add/remove actions to/from the hooks.
using Hook for uint256;

// Adding the hooks for the share token transfer
....
function setGauge(IGauge _gauge, IShareToken _shareToken) external virtual onlyOwner {
    ....
    // As we are configuring the hooks for the share token transfer, we need to get the token type
    // as it is a part of the hook configuration. We support three token types:
    // - 0: Hook.COLLATERAL_TOKEN
    // - 1: Hook.PROTECTED_TOKEN
    // - 2: Hook.DEBT_TOKEN
    uint256 tokenType = _getTokenType(silo, address(_shareToken));
    // Here we get the hooks configuration for the `after action` for the silo
    uint256 hooksAfter = _getHooksAfter(silo);
    // We construct the action that we want to add to the hooks configuration.
    // The hooks are stored as a bitmap and can be combined with bitwise OR operation.
    // In this particular case we combine the token type and the `SHARE_TOKEN_TRANSFER` action.
    // Which allows us to build an action that will work for a share token with particular token type.
    uint256 action = tokenType | Hook.SHARE_TOKEN_TRANSFER;
    // We add the action to the hooks configuration using the `addAction` function,
    // or if it is needed to override hooks configuration we can set the new value directly.
    // It is recommended to use `addAction` and `removeAction` when working with hook.
    // It is expected that hooks bitmap will store settings for multiple hooks and utility
    // functions like `addAction` and `removeAction` will make sure to not override
    // other hooks' settings.
    hooksAfter = hooksAfter.addAction(action);
    // We update the hooks configuration for the `after action` for the silo
    _setHookConfig(silo, _HOOKS_BEFORE_NOT_CONFIGURED, hooksAfter);
    ....
}

// Removing the hooks for the share token transfer
....
function removeGauge(IShareToken _shareToken) external virtual onlyOwner {
    ....
    // As we are removing the hooks for the share token transfer, we need to get the token type
    // as it is a part of the hook configuration.
    uint256 tokenType = _getTokenType(silo, address(_shareToken));
    // Here we get the hooks configuration for the `after action` for the silo
    uint256 hooksAfter = _getHooksAfter(silo);
    // We remove the action from the hooks configuration
    hooksAfter = hooksAfter.removeAction(tokenType);
    // We update the hooks configuration for the `after action` for the silo
    _setHookConfig(silo, _HOOKS_BEFORE_NOT_CONFIGURED, hooksAfter);
    ....
}
```
To see a complete example of the `GaugeHookReceiver` implementation, please refer to the [GaugeHookReceiver.sol](https://github.com/silo-finance/silo-contracts-v2/blob/develop/silo-core/contracts/utils/hook-receivers/gauge/GaugeHookReceiver.sol) file. \
For more information about the `Hook` library and supported actions, please refer to the [Hook.sol](https://github.com/silo-finance/silo-contracts-v2/blob/develop/silo-core/contracts/lib/Hook.sol) file.
The `Hook` library also contains helper methods for building actions.

## 2. Handling notifications from the silo lending market (matchAction)
After the hook has been configured, the silo lending market will start to send notifications to the hook receiver. Based on the hook configuration, notifications can be sent from the silos or from the share tokens.

### Example of handling notifications in the `GaugeHookReceiver`
```solidity
// We use `Hook` library for uint256 to be able to use the `matchAction` function.
using Hook for uint256;

// Handling the notifications from the share tokens
....
function afterAction(address _silo, uint256 _action, bytes calldata _inputAndOutput)
    ....
    // We check if the action is in the hooks configuration if not, we return
    if (!_getHooksAfter(_silo).matchAction(_action)) return;
    ....
```

## 3. Handling notifications from the silo lending market (decoding the input)
Every hook notification contains the input data. The input data is a `bytes` type and it contains the data that was encoded in the action. For each action, the input data is different. You can see the input data for each action in the hooks documentation[Hook.md](https://github.com/silo-finance/silo-contracts-v2/blob/develop/silo-core/docs/Hooks.md) file.

### Example of the input data decoding from the share tokens in the `GaugeHookReceiver`
```solidity
// We use `Hook` library for bytes to be able to use helper functions for decoding the input data.
using Hook for bytes;

// Handling the notifications from the share tokens
....
function afterAction(address _silo, uint256 _action, bytes calldata _inputAndOutput)
    ....
    // To decode the input data, we use the `afterTokenTransferDecode` function.
    Hook.AfterTokenTransfer memory input = _inputAndOutput.afterTokenTransferDecode();
    ....
}
```
Every action in the silo has a helper function to decode a data from the input. You can see the helper functions in the [Hook.md](https://github.com/silo-finance/silo-contracts-v2/blob/develop/silo-core/docs/Hooks.md) file.
