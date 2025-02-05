# Silo V2 Hooks Quickstart - make steps

## Initial steps to create this repository from scratch

```shell
git submodule add --name silo-contracts-v2 https://github.com/silo-finance/silo-contracts-v2 gitmodules/silo-contracts-v2
git submodule add --name openzeppelin-contracts-5 https://github.com/OpenZeppelin/openzeppelin-contracts gitmodules/openzeppelin-contracts-5

forge update

cd gitmodules/silo-contracts-v2
git checkout <commit>
```


## Custom errors definition

You can regenerate custom error definitions for foundry by running:

```shell
cd custom 

python3 findCustomErrors.py ../gitmodules/openzeppelin-contracts-5/contracts/ ../contracts/errors/OZErrors.sol
python3 findCustomErrors.py ../gitmodules/silo-contracts-v2/silo-core/ ../contracts/errors/CollectedErrors.sol

you want to adjust output files:
- remove errors with custom types 
- or include path to custom types definitions
```
