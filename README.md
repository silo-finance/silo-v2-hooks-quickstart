# Silo V2 Hooks Quickstart

## Prepare local environment

```shell
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

## Init

```shell
git submodule add --name forge-std https://github.com/foundry-rs/forge-std gitmodules/forge-std
git submodule add --name silo-contracts-v2 https://github.com/silo-finance/silo-contracts-v2 gitmodules/silo-contracts-v2

forge update

cd gitmodules/silo-contracts-v2
git checkout <commit>
```
