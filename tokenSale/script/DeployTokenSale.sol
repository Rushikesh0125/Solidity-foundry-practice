// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Script} from "forge-std/Script.sol";
import {TokenSale} from "../src/TokenSale.sol";
import {Token} from "../src/Token.sol";

/**
 * @notice Script to deploy tokensale contract
 * @dev Make sure to deploy token before deploying tokensale
 * @dev Set deployed address to 'TOKENSALE_CONTRACT' in .env after running this script
 */
contract DeployTokenSale is Script{

    function run() external{
        uint deployer;
        if (block.chainid == 31337) {
            deployer = vm.envUint("DEFAULT_ANVIL_KEY");
        } else {
            deployer = vm.envUint("PRIVATE_KEY");
        }
        vm.startBroadcast(deployer);

        TokenSale voting = new TokenSale(3 ether, 5 ether, 1 ether, 2 ether, vm.envAddress("OWNER_1"), vm.envAddress("TOKEN_CONTRACT"));
    }

}