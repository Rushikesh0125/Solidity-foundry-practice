// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import {Voting} from "../src/Voting.sol";

/**
 * @title Test cases for TokenSale
 * @notice All testcases with prefix test are meant to pass when ideal conditions are followed
 * @notice All testcases with prefix testFail are meant to pass when contract execution reverts on not followinf ideal 
 */
contract VotingTest is Test {

    Voting votingContract;
    address votingAdmin;

    /**
     * @dev Set up the initial state for each test.
     */
    function setUp() public {
        bytes32[] memory candidates = new bytes32[](3);
        candidates[0] = keccak256("candidate 1");
        candidates[1] = keccak256("candidate 2");
        candidates[2] = keccak256("candidate 3");
        votingAdmin = makeAddr("Voting admin");
        votingContract = new Voting(votingAdmin,candidates);
    }

    /**
     * @dev Test case: Voting should fail to start without adding voters.
     */
    function testFail_start_voting_without_voters() public{
        vm.startPrank(votingAdmin);
        //No voters added before starting voting
        votingContract.startVoting();
        vm.stopPrank();
    }

    /**
     * @dev Test case: Fail to register a voter twice.
     */
    function testFail_register_voter_twice() public{
        vm.startPrank(votingAdmin);
        address voter = makeAddr("voter");
        //registering a voter twice
        votingContract.registerVoter(voter);
        votingContract.registerVoter(voter);
        vm.stopPrank();
    }

    /**
     * @dev Test case: Fail to register with a zero address.
     */
    function testFail_register_zero_address() public{
        vm.startPrank(votingAdmin);
        //trying to register zero address
        votingContract.registerVoter(address(0));
        vm.stopPrank();
    }

    /**
     * @dev Test case: Fail to cast a vote before voting started.
     */
    function testFail_cast_vote_before_voting_started() public{
        vm.startPrank(votingAdmin);
        address voter = makeAddr("voter");
        votingContract.registerVoter(voter);
        /// Not starting the voting
        // votingContract.startVoting();
        vm.stopPrank();

        vm.startPrank(voter);
        votingContract.castvote(1);
        vm.stopPrank();  
    }

    /**
     * @dev Test case: Fail to cast a vote with an invalid candidate id.
     */
    function testFail_cast_vote_with_invalid_candidate_id() public{
        vm.startPrank(votingAdmin);
        address voter = makeAddr("voter");
        votingContract.registerVoter(voter);
        votingContract.startVoting();
        vm.stopPrank();

        vm.startPrank(voter);
        //Only 3 candidates are there, but trying to vote for Id 6
        votingContract.castvote(6);
        vm.stopPrank();  
    }

    /**
     * @dev Test case: Fail to cast a vote with an unregistered voter.
     */
    function testFail_cast_vote_with_unregistered_voter() public{
        vm.startPrank(votingAdmin);
        address voter = makeAddr("voter");
        address voter2 = makeAddr("voter2");
        //registering voter but not voter2
        votingContract.registerVoter(voter);
        votingContract.startVoting();
        vm.stopPrank();

        vm.startPrank(voter2);
        //casting vote with unregistered voter2
        votingContract.castvote(2);
        vm.stopPrank();  
    }

    /**
     * @dev Test case: Fail to cast a vote two times.
     * @notice Voter should be able to vote only once
     */
    function testFail_cast_vote_two_times() public{
        vm.startPrank(votingAdmin);
        address voter = makeAddr("voter");
        votingContract.registerVoter(voter);
        votingContract.startVoting();
        vm.stopPrank();

        vm.startPrank(voter);
        //trying to vote two times with same voter
        votingContract.castvote(2);
        votingContract.castvote(2);
        vm.stopPrank();  
    }

    /**
     * @dev Test case: Fail to end voting before starting.
     */
    function testFail_end_voting_before_starting() public {
        vm.startPrank(votingAdmin);
        address voter = makeAddr("voter");
        votingContract.registerVoter(voter);
        //No voting started
        //votingContract.startVoting();
        votingContract.endVotingAndDeclareWinner();
        vm.stopPrank();
    }

    /**
     * @dev Test case: Cast a vote under ideal conditions.
     */
    function test_cast_vote_ideal_condition() public {
        vm.startPrank(votingAdmin);
        address voter = makeAddr("voter");
        //registering the voter
        votingContract.registerVoter(voter);
        /// starting the voting
        votingContract.startVoting();
        vm.stopPrank();

        vm.startPrank(voter);
        //number of votes of candidate 1 before casting vote is zero
        uint256 votesBefore = votingContract.getVotesCount(1);
        // casting vote to candidate 1
        votingContract.castvote(1);
        //number of votes of candidate 1 before casting vote is one
        uint256 votesAfter = votingContract.getVotesCount(1);
        //difference should be 1
        assertEq(votesAfter-votesBefore, 1);
        vm.stopPrank();
    }

    /**
     * @dev Test case: Fail to register a voter after voting starts.
     */
    function testFail_register_voter_after_voting_starts() public{
        vm.startPrank(votingAdmin);
        address voter = makeAddr("voter");
        address voter2 = makeAddr("voter2");
        //registered voter before starting voting
        votingContract.registerVoter(voter);
        votingContract.startVoting();
        //trying to register voter2 after starting voting
        votingContract.registerVoter(voter2);
        vm.stopPrank();
    }

    /**
     * @dev Test case: Determine the winner after voting ends.
     */
    function test_winner_after_voting_ends() public {
        vm.startPrank(votingAdmin);
        
        address voter = makeAddr("voter");
        address voter2 = makeAddr("voter2");
        address voter3 = makeAddr("voter3");
        address voter4 = makeAddr("voter4");

        votingContract.registerVoter(voter);
        votingContract.registerVoter(voter2);
        votingContract.registerVoter(voter3);
        votingContract.registerVoter(voter4);
        /// starting the voting
        votingContract.startVoting();
        vm.stopPrank();

        vm.startPrank(voter);
        votingContract.castvote(2);
        vm.stopPrank();

        vm.startPrank(voter2);
        votingContract.castvote(1);
        vm.stopPrank();

        vm.startPrank(voter3);
        votingContract.castvote(3);
        vm.stopPrank();

        vm.startPrank(voter4);
        votingContract.castvote(3);
        vm.stopPrank();

        vm.startPrank(votingAdmin);
        votingContract.endVotingAndDeclareWinner();
        assert(votingContract.winnerId()==3);
        vm.stopPrank();
    }

}
