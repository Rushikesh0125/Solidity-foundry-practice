// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Script} from "forge-std/Script.sol";
import {TokenSwap} from "../src/TokenSwap.sol";
import {TokenB} from "../src/TokenB.sol";
import {TokenA} from  "../src/TokenA.sol";

/**
 * @dev Make sure to add liquidity before this script
 * @notice script to swap token A for token B
 */
contract SwaptokenAForTokenB is Script{
    TokenSwap tokenswap = TokenSwap(vm.envAddress("TOKEN_SWAP"));
    TokenA tokenA = TokenA(vm.envAddress("TOKEN_A"));

    function run() external {

        uint privateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(privateKey);

        tokenA.approve(address(tokenswap), 100*1e18);

        tokenswap.swapTokenAForTokenB(100*1e18);

    }
}