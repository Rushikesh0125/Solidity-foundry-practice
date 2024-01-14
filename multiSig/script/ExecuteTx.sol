// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Script} from "forge-std/Script.sol";
import {MultiSigWallet} from "../src/MultiSigWallet.sol";

/**
 * @notice Script to Execute a transaction
 * @dev Make sure to get confirmations on a submitted transaction [./GetConfirmations.sol] before this script
 */
contract ExecuteTx is Script{

    MultiSigWallet multisigContract = MultiSigWallet(payable(vm.envAddress("MULTISIG_CONTRACT")));

    function run() external{
        uint deployer;
        if (block.chainid == 31337) {
            deployer = vm.envUint("DEFAULT_ANVIL_KEY");
        } else {
            deployer = vm.envUint("PRIVATE_KEY");
        }
        vm.startBroadcast(deployer);
        
        multisigContract.executeTransaction(0);
    }

}