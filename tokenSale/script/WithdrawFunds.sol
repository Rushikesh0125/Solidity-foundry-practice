// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Script} from "forge-std/Script.sol";
import {TokenSale} from "../src/TokenSale.sol";
import {Token} from "../src/Token.sol";

/**
 * @notice Script to withdraw funds 
 * @dev Run this script after ending public sale [./EndPublicSale.sol]
 * @dev Uncommnet the second interaction in [./BuyInPublicSale.sol] to run this successfully
 */
contract WithdrawFunds is Script{
    TokenSale tokensaleContract = TokenSale(payable(vm.envAddress("TOKENSALE_CONTRACT")));

    function run() external{
        uint deployer;
        if (block.chainid == 31337) {
            deployer = vm.envUint("DEFAULT_ANVIL_KEY");
        } else {
            deployer = vm.envUint("PRIVATE_KEY");
        }
        vm.startBroadcast(deployer);
        tokensaleContract.withdraw();
    }

}