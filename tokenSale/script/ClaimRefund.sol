// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Script} from "forge-std/Script.sol";
import {TokenSale} from "../src/TokenSale.sol";
import {Token} from "../src/Token.sol";

/**
 * @notice Script to claim refund
 * @dev Run this script after ending public sale[./EndPublicSale.sol]
 */
contract ClaimRefund is Script{
    TokenSale tokensaleContract = TokenSale(payable(vm.envAddress("TOKENSALE_CONTRACT")));

    function run() external{
        uint buyer;
        if (block.chainid == 31337) {
            buyer = vm.envUint("DEFAULT_ANVIL_KEY2");
        } else {
            buyer = vm.envUint("PRIVATE_KEY2");
        }
        vm.startBroadcast(buyer);
        tokensaleContract.claimRefund();
    }

}