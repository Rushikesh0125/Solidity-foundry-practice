// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";


/**
 * @title Voting
 * @dev Smart contract for conducting an election with access control and vote counting features.
 * @notice Uses OpenZeppelin's AccessControl for role-based access control.
 */
contract Voting is AccessControl{

    /// emits on start of voting with candidate list as param
    event VotingStarted(
        Candidate[] candidates, 
        uint256 startTime
    ); 
    /// emits on end of voting and announces Winner
    event VotingEnded(
        bytes32 winnerName, 
        uint256 candidateId, 
        uint256 votes, 
        uint256 endTime
    ); 
    event voteCasted(
        address indexed voter
    ); 

    /// @notice sturct for voter information
    struct Voter{
        bool hasVoted;
        uint256 votedTo;
        address voterAddress;
    }

    /// @notice sturct for candidate information
    struct Candidate{
        bytes32 name;
        uint256 candidateId;
        uint256 numberOfVotes;
    }

    /// @notice Enum representing the different states of the voting process.
    enum VotingStatus {
        NOT_STARTED,
        STARTED,
        ENDED
    }

    /// @notice Voting admin role
    bytes32 public constant VOTING_ADMIN_ROLE = keccak256("VOTING_ADMIN_ROLE");

    VotingStatus public isVotingOpen;

    /// @notice winner's candidate Id
    uint256 public winnerId;

    /// @notice Number of voters
    uint256 public votersCount;

    /// @notice list of candidates
    Candidate[] public candidates;

    /// Record of registered voters mapped to voter addresses
    mapping (address => Voter) private registeredVoter;


    /**
     * @dev Constructor for initializing the voting contract.
     * @param _votingAdmin The Ethereum address to be assigned as the voting admin.
     * @param candidateNames An array of unique names for the candidates participating in the election.
     * @notice Requires at least two candidates to be provided for a valid election.
     * @notice Grants the VOTING_ADMIN_ROLE to the designated voting admin.
     * @notice Initializes the voting status to NOT_STARTED.
     * @notice Initializes the list of candidates with unique names and zero votes.
     * @notice VOTING_ADMIN_ROLE The role assigned to the voting admin.
     * @notice candidate An object representing a candidate with a unique name, candidate ID, and initial vote count.
     */
    constructor(address _votingAdmin, bytes32[] memory candidateNames) {
        require(candidateNames.length > 1, "Not enough candidates to vote for");
        _grantRole(VOTING_ADMIN_ROLE, _votingAdmin);
        isVotingOpen = VotingStatus.NOT_STARTED;
        uint256 len = candidateNames.length;
        for(uint256 i = 0; i < len; i++){
            candidates.push(Candidate({
                name:candidateNames[i],
                candidateId:i+1,
                numberOfVotes:0
            }));
        }
    }

    /// @notice modifier for access control - checks if caller is voting admin
    modifier onlyVotingAdmin {
        require(hasRole(VOTING_ADMIN_ROLE,msg.sender), "Unauthorized for this action");
        _;
    }

    /**
     * @dev Registers a voter for the upcoming election.
     * @param _voterAddress The Ethereum address of the voter to be registered.
     * @notice This function can only be called by the voting admin.
     * @notice Requires a valid and non-zero Ethereum address for registration.
     * @notice The registration is only allowed when the voting status is NOT_STARTED.
     * @notice Reverts if voter is not already registered.
     * @notice Increases the total count of registered voters upon successful registration.
     * @notice onlyVotingAdmin Only the designated voting admin can execute this function.
     */
    function registerVoter(address _voterAddress) external onlyVotingAdmin {
        require(_voterAddress != address(0), "Invalid voter address");
        require(isVotingOpen == VotingStatus.NOT_STARTED, "Voting has already started");
        require(registeredVoter[_voterAddress].voterAddress == address(0), "Already registered");
        votersCount++;
        registeredVoter[_voterAddress] = Voter({
            hasVoted:false,
            votedTo:0,
            voterAddress:_voterAddress
        });
    }

    /**
     * @dev Initiates the start of the voting process.
     * @notice This function can only be called by the voting admin.
     * @notice It requires that at least one voter is registered.
     * @notice The voting status must be in the NOT_STARTED state.
     * @notice Changes the voting status to STARTED upon successful start of voting.
     * @notice onlyVotingAdmin Only the designated voting admin can execute this function.
     * @notice Emits a `VotingStarted` event with the list of candidates and the timestamp of the start.
     */
    function startVoting() external onlyVotingAdmin {
        require(votersCount > 0, "No Voters registered");
        require(isVotingOpen == VotingStatus.NOT_STARTED,"Voting already started or is ended");
        isVotingOpen = VotingStatus.STARTED;
        emit VotingStarted(candidates,block.timestamp);
    }

    /**
     * @dev Allows a registered voter to cast a vote for a specific candidate.
     * @param candidateId The unique identifier of the candidate to vote for.
     * @notice This function can only be called when the voting status is set to STARTED.
     * @notice The candidateId must be a valid within the range of exisitng candidate ids.
     * @notice The caller must be a registered voter and not have voted already.
     * @notice Emits a `voteCasted` event upon successful voting.
     */
    function castvote(uint256 candidateId) external {
        require(isVotingOpen == VotingStatus.STARTED, "Voting not started yet");
        require(candidateId > 0 && candidateId <= candidates.length,"Invalid candidate Id");
        require(registeredVoter[msg.sender].voterAddress == msg.sender, "Not a registered voter");
        require(!registeredVoter[msg.sender].hasVoted, "Already Voted");

        Candidate storage candidate  = candidates[candidateId-1];
        candidate.numberOfVotes += 1;
        registeredVoter[msg.sender].hasVoted=true;
        registeredVoter[msg.sender].votedTo = candidateId;

        emit voteCasted(msg.sender);
    }

    /**
     * 
     * @dev Ends the voting process and declares the winner (if any).
     * @notice This function can only be called by the voting admin.
     * @notice It requires that the voting status is currently in the STARTED state.
     * @notice Changes the voting status to ENDED upon successful end of voting.
     * @notice Determines the winner by comparing the number of votes each candidate received.
     * @notice Emits a `VotingEnded` event with the winner's information or indicates if no votes were casted.
    */
    function endVotingAndDeclareWinner() external onlyVotingAdmin{
        require(isVotingOpen == VotingStatus.STARTED, "Voting not started yet or it is already ended");
        isVotingOpen = VotingStatus.ENDED;
        Candidate memory winner = candidates[0];
        uint256 len = candidates.length;
        for(uint256 i = 1; i < len; i++){
            if(candidates[i].numberOfVotes > candidates[i-1].numberOfVotes){
                winner = candidates[i];
                winnerId = i+1;
            }
        }
        if(winner.numberOfVotes == 0){
            emit VotingEnded("No Votes Casted", 0, 0, block.timestamp);
        }else{
            emit VotingEnded(winner.name, winner.candidateId, winner.numberOfVotes, block.timestamp);
        }
    }

    /**
     * @dev Retrieves the number of votes received by a specific candidate.
     * @param _candidateId The unique identifier of the candidate.
     * @return The total number of votes received by the specified candidate.
     * @notice This function is view-only and does not modify the contract state.
     */
    function getVotesCount(uint256 _candidateId) external view returns(uint256){
        return candidates[_candidateId-1].numberOfVotes;
    }



}