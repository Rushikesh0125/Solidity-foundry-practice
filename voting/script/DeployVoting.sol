// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Script} from "forge-std/Script.sol";
import {Voting} from "../src/Voting.sol";

/**
 * @dev Set deployed address to 'VOTING_CONTRACT' in .env after running this script
 * @notice script to deploy Voting
 */
contract DeployVoting is Script{

    function run() external{
        uint deployer;
        if (block.chainid == 31337) {
            deployer = vm.envUint("DEFAULT_ANVIL_KEY");
        } else {
            deployer = vm.envUint("PRIVATE_KEY");
        }
        vm.startBroadcast(deployer);
        address votingAdmin = vm.envAddress("VOTING_ADMIN");
        bytes32 candA = stringToBytes32(vm.envString("CANDIDATE_A"));
        bytes32 candB = stringToBytes32(vm.envString("CANDIDATE_B"));

        bytes32[] memory candidates =  new bytes32[](2);
        candidates[0] = candA;
        candidates[1] = candB;

        Voting voting = new Voting(votingAdmin, candidates);
    }

    function stringToBytes32(string memory source) public pure returns (bytes32 result) {
    bytes memory tempEmptyStringTest = bytes(source);
    if (tempEmptyStringTest.length == 0) {
        return 0x0;
    }

    assembly {
        result := mload(add(source, 32))
    }
}

}