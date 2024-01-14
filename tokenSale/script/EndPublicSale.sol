// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Script} from "forge-std/Script.sol";
import {TokenSale} from "../src/TokenSale.sol";
import {Token} from "../src/Token.sol";

/**
 * @notice Script to end public sale 
 * @dev Run this script after starting public sale & buying in public sale [./StartPublicSale.sol] & [./BuyInPublicSale.sol]
 */
contract EndPublicSale is Script{
    TokenSale tokensaleContract = TokenSale(payable(vm.envAddress("TOKENSALE_CONTRACT")));

    function run() external{
        uint deployer;
        if (block.chainid == 31337) {
            deployer = vm.envUint("DEFAULT_ANVIL_KEY");
        } else {
            deployer = vm.envUint("PRIVATE_KEY");
        }
        vm.startBroadcast(deployer);
        tokensaleContract.endPublicSale();

    }

}