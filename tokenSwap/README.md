# Token Swap Contract - Assignment

## About

### This project contains contract for tokens and another contract to swap these ERC20 tokens both ways

### Directories

```
    |_script
    |   |_DeployTokenA.sol
    |   |_DeployTokenB.sol
    |   |_DeployTokenSwapContract.sol
    |
    |_src
    |   |_TokenA.sol
    |   |_TokenB.sol
    |   |_TokenSwap.sol
    |
    |_test
        |_TokenSwap.t.sol

```

### Design Considerations

- Token A & Token B are standard ERC20 tokens

- Deployer can pass addresses of token A & token B in constructor.

- Token swap contract follows a static/fixed exchange rate.

- Exchange rate can be set in constructor in form of amount of token A to be offered in exchange of 100 token B's.

- Anyone can add liquidity initially as there are no roles.

- Two seperate function for swapping token B for token A & vice versa.

- SafeErc20 library is used for ERC20 operations like transfers.

- ... For More please refer comments

### Steps to Initialize the project

```
git clone repoUrl

make install

forge build
```

### Steps to run tests

### Steps to Run the tests 🔧 <a name = "tests"></a>

> All test cases with **_`testFail`_** prefix are meant to pass when there is revert

> All test cases with **_`test`_** prefix are meant to pass when ideal conditions are mimicked

```
#To compile contracts
forge build

#To run test cases
forge test

#To run test cases with gas report
forge test --gas-report

#To see the test coverage
forge coverage
```

### Steps to run scripts

> **_Make sure you create an `.env` file_**

> **_Refer `.env.example` for env variables_**

> **_To Run scipts on sepolia_**

```
Add ARGS="--network sepolia" to following commands
eg -
make deploy-voting ARGS="--network sepolia"
```

> **_Make sure to run scripts in following order_**

> **_Also make sure to assign and save values of deployed contract addresses in env after each deployment_**

```
# To deploy token A
make deploy-tokenA
# Save deployed address in env to 'TOKEN_A' variable

# To deploy token B
make deploy-tokenB
# Save deployed address in env to 'TOKEN_B' variable

#To deploy tokenSwap contract
make deploy-tokenSwapContract
# Save deployed address in env to 'TOKEN_SWAP' variable

#To add both token's liquidity in token swap contract
make addLiquidityForBothTokens

#To swap token A for token B
make swapTokenAForTokenB

#To swap token B for token A
make swapTokenBForTokenA

```
