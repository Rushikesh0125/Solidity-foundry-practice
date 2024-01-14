// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Script} from "forge-std/Script.sol";
import {TokenSale} from "../src/TokenSale.sol";
import {Token} from "../src/Token.sol";

/**
 * @notice Script to buy while presale is open
 * @dev Run this script after starting public sale [./StartPublicSale.sol]
 * @dev Uncomment the second interaction in order to run [./withdrawFunds.sol] & [./withdrawRemTokens.sol] successfully
 */
contract BuyInPublicsale is Script{
    TokenSale tokensaleContract = TokenSale(payable(vm.envAddress("TOKENSALE_CONTRACT")));

    function run() external{
        uint buyer3;
        if (block.chainid == 31337) {
            buyer3 = vm.envUint("DEFAULT_ANVIL_KEY3");
        } else {
            buyer3 = vm.envUint("PRIVATE_KEY3");
        }
        vm.startBroadcast(buyer3);
        (bool callSuccess,) = address(tokensaleContract).call{value: 1e17}(
            abi.encodeWithSignature("buyTokens()")
        );
        require(callSuccess, "call failed");
        vm.stopBroadcast();

        // uint buyer4;
        // if (block.chainid == 31337) {
        //     buyer4 = vm.envUint("DEFAULT_ANVIL_KEY2");
        // } else {
        //     buyer4 = vm.envUint("PRIVATE_KEY2");
        // }
        // vm.startBroadcast(buyer3);
        // (bool callSuccess1,) = address(tokensaleContract).call{value: 1e17}(
        //     abi.encodeWithSignature("buyTokens()")
        // );
        // require(callSuccess1, "call failed");

    }

}