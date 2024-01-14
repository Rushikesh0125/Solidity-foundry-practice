# Voting Contract - Assignment

## About

### This project contains contract for voting for candidates and managing a decentralized election

### Directories

```
    |_script
    |   |_CastVotes.sol
    |   |_DeployVoting.sol
    |   |_EndVoting.sol
    |   |_RegisterVotingAndStartVoting.sol
    |
    |_src
    |   |_Voting.sol
    |
    |_test
        |_Voting.t.sol

```

### Design Considerations

- Constructor takes in address of voting admin and array of candidates.
- Atleast two candidates should be there in candidates array.
- Only voting admin can register voters.
- Voters can be registered before voting starts.
- Registered voters can cast votes while voting is open.
- Every voter can cast vote only once.
- Contract also consideres Zero voting scenario. No voter will be announced if zero votes casted.
- .. For More please refer comments

### Steps to Initialize the project

```
git clone https://github.com/Rushikesh0125/SolidityAssignment.git

cd voting

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
# To deploy voting contract
make deploy-voting
# Save deployed address in env to 'VOTING_CONTRACT' variable

# To register a voter and open voting process
make register-voters-and-start-voting

#To cast a vote
make cast-vote

#To end voting process
make end-voting


```
