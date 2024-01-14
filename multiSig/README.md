# MultiSig Wallet Contract - Assignment

## About

### This project contains contract for multi-sig wallet, which allows owners to submit, confirm(approvals), and execute transaction after enough confirmations.

### Directories

```
    |_script
    |   |_DeployMultiSig.sol
    |   |_DepositeFunds.sol
    |   |_ExecuteTx.sol
    |   |_GetConfirmations.sol
    |   |_SubmitTx.sol
    |
    |_src
    |   |_MultiSigWallet.sol
    |
    |_test
        |_MultiSig.t.sol

```

### Design Considerations

- Deployer sets Owners and minimum required confirmations on a transaction.

- Any owner can submit a transaction

- To confirm a transaction -

  1. Only owner can confirm
  2. Only transactions which exist and are not executed can confirm
  3. Any owner can confirm a transaction only `once`

- To execute a transaction -

  1. Only an owner can execute
  2. A transaction can be executed only if minimum required confirmations are there
  3. A transaction can be executed only if non executed and existing

- To revoke a transaction -

  1. Only an owner who gave confirmation earlier can revoke
  2. Confirmation can be revoked only before execution

- Only mappings are used for 'Owners' & 'Transaction' for gas efficient operations

- There is max cap on number of owners to avoid longer standing transactions

- .. For More please refer comments

### Steps to Initialize the project

```
git clone https://github.com/Rushikesh0125/SolidityAssignment.git

cd multiSig

# Running this in submodule[assignment] might install dependecies for all submodules
# Still make sure to run this for each submodule[assignment]
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
# To deploy multi-sig wallet contract
make deploy-multi-sig
# Save deployed address in env to 'MULTISIG_CONTRACT' variable

# To Deposite funds into wallet
make deposite-funds

#To submit a transaction in multi-sig wallet
make submit-tx

#To confirm transaction by multiple owner
make get-confirmations

# To execute transaction
make execute-tx


```
