# Silo hooks system
The Silo Protocol Hooks System provides an extensible mechanism for interacting with core actions like deposits, withdrawals, borrowing, repayments, collateral transitions, switching collateral, flash loans, and liquidations. Hooks allow external systems to execute custom logic before or after protocol actions, offering flexibility for validation, logging, or integration with external contracts. While the protocol is fully functional without hooks, they enhance its modularity and allow for seamless interaction with other decentralized systems. For more information see [Hooks.md](https://github.com/silo-finance/silo-contracts-v2/blob/develop/silo-core/docs/Hooks.md) and [WorkWithHooks.md](./WorkWithHooks.md). Curious about the Silo Protocol? Check out the [Silo Protocol Documentation](https://docs.silo.finance/).

### Silo V2 Hooks Quickstart

```shell
# Prepare local environment

# 1. Install Foundry 
# https://book.getfoundry.sh/getting-started/installation

# 2. Clone repository
$ git clone https://github.com/silo-finance/silo-v2-hooks-quickstart.git

# 3. Open folder
$ cd silo-v2-hooks-quickstart

# 4. Initialize submodules
$ git submodule update --init --recursive
```

### Tests
```shell
forge test
```
