// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Script} from "forge-std/Script.sol";
import {MultiSigWallet} from "../src/MultiSigWallet.sol";

/**
 * @notice Script to get confrmation on a submitted transaction
 * @dev Make sure to submit a transaction [./SubmitTx.sol] before this script
 */
contract GetConfirmations is Script{

    MultiSigWallet multisigContract = MultiSigWallet(payable(vm.envAddress("MULTISIG_CONTRACT")));

    function run() external{
        uint deployer;
        if (block.chainid == 31337) {
            deployer = vm.envUint("DEFAULT_ANVIL_KEY");
        } else {
            deployer = vm.envUint("PRIVATE_KEY");
        }
        vm.startBroadcast(deployer);
        
        multisigContract.confirmTransaction(0);

        vm.stopBroadcast();

        uint owner2;

        if (block.chainid == 31337) {
            owner2  = vm.envUint("DEFAULT_ANVIL_KEY2");
        } else {
            owner2 = vm.envUint("PRIVATE_KEY2");
        }
        vm.startBroadcast(owner2);

        multisigContract.confirmTransaction(0);

        vm.stopBroadcast();

        uint owner3;

        if (block.chainid == 31337) {
            owner3  = vm.envUint("DEFAULT_ANVIL_KEY3");
        } else {
            owner3 = vm.envUint("PRIVATE_KEY3");
        }
        vm.startBroadcast(owner3);

        multisigContract.confirmTransaction(0);
    }

}