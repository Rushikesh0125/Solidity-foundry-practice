// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {MultiSigWallet} from "../src/MultiSigWallet.sol";
import {Test, console2} from "forge-std/Test.sol";

/**
 * @title Test cases for Multisig wallet contract
 * @notice All testcases with prefix test are meant to pass when ideal conditions are followed
 * @notice All testcases with prefix testFail are meant to pass when contract execution reverts on not followinf ideal 
 */
contract MultiSigTest is Test{

    MultiSigWallet public multiSigContract;
    address owner1;
    address owner2;
    address owner3;
    address owner4;

    /// setup for tests
    function setUp() public {
        address[] memory owners = new address[](4);

        owner1 = makeAddr("owner1");
        owner2 = makeAddr("owner2");
        owner3 = makeAddr("owner3");
        owner4 = makeAddr("owner4");

        owners[0] = owner1;
        owners[1] = owner2;
        owners[2] = owner3;
        owners[3] = owner4;
        
        multiSigContract = new MultiSigWallet(owners, 2);

        address[] memory fetchedOwners = multiSigContract.getOwners();

        assertEq(fetchedOwners[0], owner1);
        assertEq(fetchedOwners[1], owner2);
        assertEq(fetchedOwners[2], owner3);
        assertEq(fetchedOwners[3], owner4);
    
    }

    /**
     * @notice Test for submitting transaction by owner
     */
    function test_submit_transaction_by_owner() public{
        vm.startPrank(owner2);
        address destAddress = makeAddr("dest");
        uint valueToSend = 1e17;
        bytes memory data = bytes("test");
        multiSigContract.submitTransaction(destAddress, valueToSend,data);
        vm.stopPrank();
    }

    /**
     * @notice Test for submitting transaction by non owner should revert
     */
    function testFail_submit_transaction_by_non_owner() public{
        address randomAddress = makeAddr("random");
        vm.startPrank(randomAddress);
        address destAddress = makeAddr("dest");
        uint valueToSend = 1e17;
        bytes memory data = bytes("test");
        multiSigContract.submitTransaction(destAddress, valueToSend,data);
        vm.stopPrank();
    }

    /**
     * @notice Test for recorded state variables
     */
    function test_submitted_transaction_recorded() public{
        vm.startPrank(owner2);
        // preparing data and submitting transactions
        address destAddress = makeAddr("dest");
        uint valueToSend = 1e17;
        bytes memory data = bytes("test");
        uint id = multiSigContract.submitTransaction(destAddress, valueToSend,data);

        // getting tx data 
        (
            address to, 
            uint val, 
            bytes memory txData, 
            bool executed, 
            uint comfirmations
        ) = multiSigContract.getTransaction(id);
        
        // assertion for checking data equalities
        assertEq(to, destAddress);
        assertEq(val, valueToSend);
        assertEq(txData, data);
        assertEq(executed, false);
        assertEq(comfirmations, 0);

        vm.stopPrank();
    }

    /**
     * @notice Test for confirming the transaction by owner
     */
    function test_confirmation_by_owner() public {
        vm.startPrank(owner2);
        // preparing data and submitting transactions
        address destAddress = makeAddr("dest");
        uint valueToSend = 1e17;
        bytes memory data = bytes("test");
        uint id = multiSigContract.submitTransaction(destAddress, valueToSend,data);

        // confirmation
        multiSigContract.confirmTransaction(id);

        vm.stopPrank();

        vm.startPrank(owner1);

        multiSigContract.confirmTransaction(id);

        // getting tx data 
        (
            address to, 
            uint val, 
            bytes memory txData, 
            bool executed, 
            uint comfirmations
        ) = multiSigContract.getTransaction(id);

        assertEq(to, destAddress);
        assertEq(val, valueToSend);
        assertEq(txData, data);
        assertEq(executed, false);
        assertEq(comfirmations, 2);

        vm.stopPrank();
    }
    
    /**
     * @notice Test for confirmation by a non owner
     */
    function testFail_confirmation_by_non_owner() public {
        vm.startPrank(owner2);
        // preparing data and submitting transactions
        address destAddress = makeAddr("dest");
        uint valueToSend = 1e17;
        bytes memory data = bytes("test");
        uint id = multiSigContract.submitTransaction(destAddress, valueToSend,data);

        multiSigContract.confirmTransaction(id);

        vm.stopPrank();
        //non owner
        vm.startPrank(destAddress);

        multiSigContract.confirmTransaction(id);

        vm.stopPrank();
    }

    /**
     * @notice Test for Executing transaction when wallet have no funds
     */
    function testFail_execution_by_owner_without_deposite() public {
        vm.startPrank(owner2);
        // preparing data and submitting transactions
        address destAddress = makeAddr("dest");
        uint valueToSend = 1e17;
        bytes memory data = bytes("test");
        uint id = multiSigContract.submitTransaction(destAddress, valueToSend,data);

        // not sending eth to contract
        // vm.deal(address(multiSigContract), 1 ether);

        multiSigContract.confirmTransaction(id);

        vm.stopPrank();

        vm.startPrank(owner3);

        multiSigContract.confirmTransaction(id);

        vm.stopPrank();

        vm.startPrank(owner1);

        multiSigContract.confirmTransaction(id);

        multiSigContract.executeTransaction(id);

        vm.stopPrank();
    }

    /**
     * @notice Test for executing transaction by owner
     */
    function test_execution_by_owner() public {
        vm.startPrank(owner2);
        // preparing data and submitting transactions
        address destAddress = makeAddr("dest");
        uint valueToSend = 1e17;
        bytes memory data = bytes("test");
        uint id = multiSigContract.submitTransaction(destAddress, valueToSend,data);

        multiSigContract.confirmTransaction(id);
        // sending eth to contract
        vm.deal(address(multiSigContract), 1 ether);

        vm.stopPrank();

        vm.startPrank(owner3);

        multiSigContract.confirmTransaction(id);

        vm.stopPrank();

        vm.startPrank(owner1);

        multiSigContract.confirmTransaction(id);

        multiSigContract.executeTransaction(id);

        (
            , 
            , 
            , 
            bool executed, 
            
        ) = multiSigContract.getTransaction(id);

        assertEq(executed, true);

        assertEq(destAddress.balance, 1e17);

        vm.stopPrank();
    }

    /**
     * @notice Test for execution of already executed transaction
     */
    function testFail_execution_of_already_executed_tx() public {
        vm.startPrank(owner2);
        // preparing data and submitting transactions
        address destAddress = makeAddr("dest");
        uint valueToSend = 1e17;
        bytes memory data = bytes("test");
        uint id = multiSigContract.submitTransaction(destAddress, valueToSend,data);

        multiSigContract.confirmTransaction(id);
        // sending eth to contract
        vm.deal(address(multiSigContract), 1 ether);

        vm.stopPrank();

        vm.startPrank(owner3);

        multiSigContract.confirmTransaction(id);

        vm.stopPrank();

        vm.startPrank(owner1);

        multiSigContract.confirmTransaction(id);

        multiSigContract.executeTransaction(id);

        vm.stopPrank();

        vm.startPrank(owner4);

        multiSigContract.executeTransaction(id);

        vm.stopPrank();
    }

    /**
     * @notice Test for executing a non existing tx
     */
    function testFail_execution_of_non_exisiting_tx() public {
        vm.startPrank(owner2);
        // preparing data and submitting transactions
        address destAddress = makeAddr("dest");
        uint valueToSend = 1e17;
        bytes memory data = bytes("test");
        uint id = multiSigContract.submitTransaction(destAddress, valueToSend,data);

        multiSigContract.confirmTransaction(id);
        // sending eth to contract
        vm.deal(address(multiSigContract), 1 ether);

        vm.stopPrank();

        vm.startPrank(owner1);

        multiSigContract.confirmTransaction(id);

        //trying to execute non exisiting transaction
        multiSigContract.executeTransaction(id+1e10);

        vm.stopPrank();

    }

    /**
     * @notice Test for confirmation of non exisiting tx
     */
    function testFail_confirming_non_exisiting_tx() public {
        vm.startPrank(owner2);
        // preparing data and submitting transactions
        address destAddress = makeAddr("dest");
        uint valueToSend = 1e17;
        bytes memory data = bytes("test");
        uint id = multiSigContract.submitTransaction(destAddress, valueToSend,data);

        multiSigContract.confirmTransaction(id);
        // sending eth to contract
        vm.deal(address(multiSigContract), 1 ether);

        vm.stopPrank();

        vm.startPrank(owner1);

        //trying to confirm non exisiting transaction
        multiSigContract.confirmTransaction(1e10);

        vm.stopPrank();

    }

    /**
     * @notice Test for revoking confirmed tx
     */
    function test_revoke_confirmation() public {
        vm.startPrank(owner2);
        // preparing data and submitting transactions
        address destAddress = makeAddr("dest");
        uint valueToSend = 1e17;
        bytes memory data = bytes("test");
        uint id = multiSigContract.submitTransaction(destAddress, valueToSend,data);

        multiSigContract.confirmTransaction(id);

        vm.stopPrank();

        vm.startPrank(owner1);

        multiSigContract.confirmTransaction(id);

        // getting tx data 
        (
            address to, 
            uint val, 
            bytes memory txData, 
            bool executed, 
            uint comfirmations
        ) = multiSigContract.getTransaction(id);

        assertEq(to, destAddress);
        assertEq(val, valueToSend);
        assertEq(txData, data);
        assertEq(executed, false);
        assertEq(comfirmations, 2);

        multiSigContract.revokeConfirmation(id);

        (
            , 
            , 
            , 
            , 
            uint comfirmationsAfter
        ) = multiSigContract.getTransaction(id);

        assertEq(comfirmationsAfter, 1);

        vm.stopPrank();
    }

    /**
     * @notice Test for revoking a tx after execution
     */
    function testFail_revoking_already_executed_tx() public {
        vm.startPrank(owner2);
        // preparing data and submitting transactions
        address destAddress = makeAddr("dest");
        uint valueToSend = 1e17;
        bytes memory data = bytes("test");
        uint id = multiSigContract.submitTransaction(destAddress, valueToSend,data);

        multiSigContract.confirmTransaction(id);
        // sending eth to contract
        vm.deal(address(multiSigContract), 1 ether);

        vm.stopPrank();

        vm.startPrank(owner3);

        multiSigContract.confirmTransaction(id);

        vm.stopPrank();

        vm.startPrank(owner1);

        multiSigContract.confirmTransaction(id);

        multiSigContract.executeTransaction(id);

        (
            , 
            , 
            , 
            bool executed, 
            
        ) = multiSigContract.getTransaction(id);

        assertEq(executed, true);

        multiSigContract.revokeConfirmation(id);

        vm.stopPrank();
    }



}