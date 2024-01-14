// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Script} from "forge-std/Script.sol";
import {TokenSale} from "../src/TokenSale.sol";
import {Token} from "../src/Token.sol";

/**
 * @notice Script to start presale
 * @dev Run this script after whitelisting & funding the contract with tokens [./AddWhitetlist.sol] & [./FundTokens.sol]
 */
contract StartPresale is Script{
    TokenSale tokensaleContract = TokenSale(payable(vm.envAddress("TOKENSALE_CONTRACT")));

    function run() external{
        uint deployer;
        if (block.chainid == 31337) {
            deployer = vm.envUint("DEFAULT_ANVIL_KEY");
        } else {
            deployer = vm.envUint("PRIVATE_KEY");
        }
        vm.startBroadcast(deployer);
        tokensaleContract.startPreSale();

    }

}