// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Script} from "forge-std/Script.sol";
import {TokenSale} from "../src/TokenSale.sol";
import {Token} from "../src/Token.sol";

/**
 * @notice Script to fund contract with tokens
 * @dev Run this script after whitelisting [./AddWhitetlist.sol]
 */
contract FundTokens is Script{
    TokenSale tokensaleContract = TokenSale(payable(vm.envAddress("TOKENSALE_CONTRACT")));
    Token token = Token(vm.envAddress("TOKEN_CONTRACT"));
    function run() external{
        uint deployer;
        if (block.chainid == 31337) {
            deployer = vm.envUint("DEFAULT_ANVIL_KEY");
        } else {
            deployer = vm.envUint("PRIVATE_KEY");
        }
        vm.startBroadcast(deployer);
        token.approve(address(tokensaleContract), 100_000*1e18);
        tokensaleContract.fundContractWithTokens(100_000*1e18);

    }

}