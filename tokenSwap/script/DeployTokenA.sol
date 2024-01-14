// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Script} from "forge-std/Script.sol";
import {TokenA} from "../src/TokenA.sol";

/**
 * @notice Script to deploy token A
 * @dev Set deployed address to 'TOKEN_A' in .env after running this script
 */
contract DeployTokenA is Script {

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.broadcast(deployerPrivateKey);

        TokenA tokenA = new TokenA();

    }
}