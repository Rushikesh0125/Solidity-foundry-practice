// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Script} from "forge-std/Script.sol";
import {TokenSwap} from "../src/TokenSwap.sol";

/**
 * @dev Make sure to deploy tokens before running this
 * @dev Set deployed address to 'TOKEN_SWAP' in .env after running this script
 * @notice script to deploy token swap contract
 */
contract DeployTokenswap is Script {

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.broadcast(deployerPrivateKey);
        
        address tokenA = vm.envAddress("TOKEN_A");
        address tokenB = vm.envAddress("TOKEN_B");

        TokenSwap tokenSwap = new TokenSwap(tokenA, tokenB, 50);

    }
}