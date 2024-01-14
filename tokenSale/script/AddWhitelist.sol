// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Script} from "forge-std/Script.sol";
import {TokenSale} from "../src/TokenSale.sol";
import {Token} from "../src/Token.sol";

/**
 * @notice Script to add whitelist
 * @dev Run this script after deploying both contracts
 */
contract AddWhiteList is Script{
    TokenSale tokensaleContract = TokenSale(payable(vm.envAddress("TOKENSALE_CONTRACT")));
    function run() external{
        uint deployer;
        if (block.chainid == 31337) {
            deployer = vm.envUint("DEFAULT_ANVIL_KEY");
        } else {
            deployer = vm.envUint("PRIVATE_KEY");
        }
        vm.startBroadcast(deployer);

        address[] memory whitelist = new address[](3);
        whitelist[0] = vm.envAddress("USER_1");
        whitelist[0] = vm.envAddress("USER_2");
        whitelist[0] = vm.envAddress("USER_3");

        tokensaleContract.addWhitelistedUsers(whitelist);

    }

}