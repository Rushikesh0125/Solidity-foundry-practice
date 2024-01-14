// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Script} from "forge-std/Script.sol";
import {MultiSigWallet} from "../src/MultiSigWallet.sol";

/**
 * @notice Script to deposite funds in wallets
 * @dev Make sure to deploy multisig before thiss script
 */
contract SubmitTx is Script{

    MultiSigWallet multisigContract = MultiSigWallet(payable(vm.envAddress("MULTISIG_CONTRACT")));

    function run() external{
        uint deployer;
        if (block.chainid == 31337) {
            deployer = vm.envUint("DEFAULT_ANVIL_KEY");
        } else {
            deployer = vm.envUint("PRIVATE_KEY");
        }
        vm.startBroadcast(deployer);
        
        (bool success, ) = address(multisigContract).call{value:2 ether}("");

        require(success);
    }

}