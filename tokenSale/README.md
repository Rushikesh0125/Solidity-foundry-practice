# Token Sale Contract - Assignment

## About <a name = "about"></a>

### This project contains contract for Token Sale and allows to host tokensale in two phases of presale and public sale

### Directories

```
    |_script
    |   |_AddWhitelist.sol
    |   |_BuyInPresale.sol
    |   |_BuyInPublicSale.sol
    |   |_ClaimRefund.sol
    |   |_DeployToken.sol
    |   |_DeployTokenSale.sol
    |   |_EndPresale.sol
    |   |_EndPublicSale.sol
    |   |_FundTokens.sol
    |   |_StartPresale.sol
    |   |_StartPubicSale.sol
    |   |_WithsrawFunds.sol
    |   |_WithdrawRemTokens.sol
    |
    |_src
    |   |_Token.sol
    |   |_TokenSale.sol
    |
    |_test
        |_TokenSale.t.sol

```

### Design Considerations

- Constructor takes in minimum and maximum cappes for pre and public sale.

- Constructor also initializes inital owner and address of token to sell.

- Contract uses 'Ownable' contract for enabling access control over some administrative functions.

- Enum 'SaleStages' has been used to represent different stage of sale.

- Various function to toggle this stages can only be accesed by owner

- This stages are strictly bounded to change in sequence as following

  `NotNotStarted -> PreSaleOpen -> PreSaleEnded -> PublicSaleOpen -> PublicSaleEnded`

- Functions for Funding contract with tokens, Adding whitelist can only be executed before starting the presale to ensure fairness with existing investors.

- Refunds are claimable when sales are not open and minimum capital required to be raised was not achieved in previous sale or one of the sales.

- So, If minimum capital required to be raised was not achieved in any of the two sales.. investors can claim refund.

- Meaning if presale fails to raise minimum capital then investors can claim refunds in between the pre and public sale OR after the public sale as well.

- And if public sale fails to raise minimum capital then again investors can claim refunds after public sale.

- All the pre requirement checks depending on sale stage done are as follows-

  - If Presale
    1. Whether user is whitelisted ?
    2. Amount of contribution by user is within bounds of minimum and maximum contribution ?
    3. iMaximum amount that can be raised is reached?
  - If public sale
    1. Amount of contribution by user is within bounds of minimum and maximum contribution ?
    2. Maximum amount that can be raised is reached ?

- Minimum and Maximum contribution bound for both stages are differently set & are constant to ensure fairness and avoid manipulation

        MIN_CONTRIBUTION_PRESALE = 2 * 1e16;
        MAX_CONTRIBUTION_PRESALE = 2 * 1e18;
        MIN_CONTRIBUTION_PUBLIC_SALE = 1e16;
        MAX_CONTRIBUTION_PUBLIC_SALE = 1e18;

- Exchange rates for Both stages are set constant to ensure fairness and avoid manipulation

        preSaleExchangeRate = 2000;
        publicSaleExchangeRate = 1500;

- Withdrawal of funds by owner is subjected to following conditions

  - Minimum required capital raised both sales
    i.e refunds are not issuable
  - Only After both sale stages are ended

- .. For More please refer comments in contracts and test cases

### Steps to Initialize the project

```
git clone https://github.com/Rushikesh0125/SolidityAssignment.git

cd tokenSale

# Running this in submodule[assignment] might install dependecies for all submodules
# Still make sure to run this for each submodule[assignment]
make install

forge build
```

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
# To deploy token contract
make deploy-token
# Save deployed address in env to 'TOKEN_CONTRACT' variable

# To delpoy token sale contract
make deploy-tokenSale

#To add whitelisted investors
make add-whitelist

#To fund contract with tokens
make fund-tokens

# To start the presale
make start-presale

# To buy tokens in presale
make buy-in-presale

# To end presale
make end-presale

# To start public sale
make start-publicsale

# To buy in public sale
make buy-in-publicsale

# To end public sale
make end-publicsale

# To claim refund
make claim-refund

# To withdraw funds
make withdraw-funds

# To withdraw remeaning tokens
make withdraw-tokens


```
