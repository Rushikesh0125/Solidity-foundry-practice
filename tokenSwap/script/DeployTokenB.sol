// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Script} from "forge-std/Script.sol";
import {TokenB} from "../src/TokenB.sol";

/**
 * @notice Script to deploy token B
 * @dev Set deployed address to 'TOKEN_B' in .env after running this script
 */
contract DeployB is Script {

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.broadcast(deployerPrivateKey);

        TokenB tokenB = new TokenB();

    }
}