// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Script} from "forge-std/Script.sol";
import {TokenSale} from "../src/TokenSale.sol";
import {Token} from "../src/Token.sol";

/**
 * @notice Script to buy while presale is open
 * @dev Run this script after starting presale [./StartPresale.sol]
 */
contract BuyInPresale is Script{
    TokenSale tokensaleContract = TokenSale(payable(vm.envAddress("TOKENSALE_CONTRACT")));

    function run() external{
        uint deployer;
        if (block.chainid == 31337) {
            deployer = vm.envUint("DEFAULT_ANVIL_KEY");
        } else {
            deployer = vm.envUint("PRIVATE_KEY");
        }
        vm.startBroadcast(deployer);
        (bool callSuccess,) = address(tokensaleContract).call{value: 2*1e17}(
            abi.encodeWithSignature("buyTokens()")
        );
        require(callSuccess, "call failed");
        vm.stopBroadcast();
        uint user2 ;
        if (block.chainid == 31337) {
            user2 = vm.envUint("DEFAULT_ANVIL_KEY2");
        } else {
            user2 = vm.envUint("PRIVATE_KEY2");
        }
        vm.startBroadcast(user2);
        (bool success2, ) = address(tokensaleContract).call{value:2*1e17}(
            abi.encodeWithSignature("buyTokens()")
        );
        require(success2,"call 2 failed");


    }

}