// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Script} from "forge-std/Script.sol";
import {TokenSwap} from "../src/TokenSwap.sol";
import {TokenB} from "../src/TokenB.sol";
import {TokenA} from  "../src/TokenA.sol";

/**
 * @dev Make sure to add liquidity before this script
 * @notice script to swap token B for token A
 */
contract SwaptokenBForTokenA is Script{
    TokenSwap tokenswap = TokenSwap(vm.envAddress("TOKEN_SWAP"));
    TokenB tokenB = TokenB(vm.envAddress("TOKEN_B"));

    function run() external {

        uint privateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(privateKey);

        tokenB.approve(address(tokenswap), 200*1e18);

        tokenswap.swapTokenBForTokenA(200*1e18);

    }
}