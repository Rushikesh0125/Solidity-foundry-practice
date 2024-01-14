// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Script} from "forge-std/Script.sol";
import {Voting} from "../src/Voting.sol";

/**
 * @dev Make sure to Deploy voting contract [./DeployVoting.sol] before running this 
 * @notice script to regiter voters and start start voting
 */
contract RegisterVotersAndStartVoting is Script{

    Voting votingContract = Voting(vm.envAddress("VOTING_CONTRACT"));

    function run() external{
        uint deployer;
        if (block.chainid == 31337) {
            deployer = vm.envUint("DEFAULT_ANVIL_KEY");
        } else {
            deployer = vm.envUint("PRIVATE_KEY");
        }
        vm.startBroadcast(deployer);

        //Voter A is deployer
        votingContract.registerVoter(vm.envAddress("VOTING_ADMIN"));
        // votingContract.registerVoter(vm.envAddress("VOTER_B"));
        // votingContract.registerVoter(vm.envAddress("VOTER_C"));

        votingContract.startVoting();
        

    }

}