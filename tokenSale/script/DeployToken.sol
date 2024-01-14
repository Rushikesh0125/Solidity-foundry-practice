// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Script} from "forge-std/Script.sol";
import {Token} from "../src/Token.sol";

/**
 * @notice Script to deploy token contract
 * @dev Set deployed address to 'TOKEN_CONTRACT' in .env after running this script
 */
contract DeployToken is Script{

    function run() external{
        uint deployer;
        if (block.chainid == 31337) {
            deployer = vm.envUint("DEFAULT_ANVIL_KEY");
        } else {
            deployer = vm.envUint("PRIVATE_KEY");
        }
        vm.startBroadcast(deployer);

        Token token = new Token();
    }

}