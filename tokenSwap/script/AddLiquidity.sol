// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Script} from "forge-std/Script.sol";
import {TokenSwap} from "../src/TokenSwap.sol";
import {TokenB} from "../src/TokenB.sol";
import {TokenA} from  "../src/TokenA.sol";


/**
 * @dev Make sure to deploy tokens and tokenSwap contract
 * @notice script to add liquidity
 */
contract AddLiquidity is Script{
    TokenSwap tokenswap = TokenSwap(vm.envAddress("TOKEN_SWAP"));
    TokenA tokenA = TokenA(vm.envAddress("TOKEN_A"));
    TokenB tokenB = TokenB(vm.envAddress("TOKEN_B"));

    function run() external {

        uint privateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(privateKey);

        tokenA.approve(address(tokenswap), 10_000*1e18);

        tokenB.approve(address(tokenswap), 10_000*1e18);

        tokenswap.addLiquidityForTokenA(10_000*1e18);

        tokenswap.addLiquidityForTokenB(10_000*1e18);

        
    }
}