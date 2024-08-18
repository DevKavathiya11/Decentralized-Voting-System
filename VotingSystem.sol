// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract Voting {
    struct Voter {
        bool isRegistered;
        bool Voted;
        uint vote;
    }

    struct Candidate {
        string name;
        uint voteCount;
    }

    address public owner;
    uint public votingStartTime;
    uint public votingEndTime;
    bool public votingEnded;

    mapping(address => Voter) public voters;
    Candidate[] public candidates;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function.");
        _;
    }

    modifier onlyRegistered() {
        require(voters[msg.sender].isRegistered, "You must be registered to vote.");
        _;
    }

    modifier onlyDuringVoting() {
        require(block.timestamp >= votingStartTime && block.timestamp <= votingEndTime, "Voting is not allowed at this time.");
        _;
    }

    modifier onlyAfterVoting() {
        require(votingEnded, "Voting has not ended yet.");
        _;
    }

    constructor(string[] memory candidateNames, uint _votingStartTime, uint _votingEndTime) {
        require(_votingEndTime > _votingStartTime, "End time must be later than start time.");

        owner = msg.sender;
        votingStartTime = _votingStartTime;
        votingEndTime = _votingEndTime;
        votingEnded = false;

        for (uint i = 0; i < candidateNames.length; i++) {
            candidates.push(Candidate({
                name: candidateNames[i],
                voteCount: 0
            }));
        }
    }

    function registerVoter(address voterAddress) public onlyOwner {
        require(!voters[voterAddress].isRegistered, "Voter is already registered.");
        voters[voterAddress] = Voter({
            isRegistered: true,
            Voted: false,
            vote: 0
        });
    }

    function vote(uint8 candidateIndex) public onlyRegistered onlyDuringVoting {
        require(!voters[msg.sender].Voted, "You have already voted.");
        require(candidateIndex < candidates.length, "Invalid candidate index.");

        voters[msg.sender].Voted = true;
        voters[msg.sender].vote = candidateIndex;

        candidates[candidateIndex].voteCount += 1;
    }

    function endVoting() public onlyOwner {
        require(block.timestamp > votingEndTime, "Voting period has not ended yet.");
        votingEnded = true;
    }

    function getCandidate(uint8 candidateIndex) public view returns (string memory name, uint voteCount) {
        require(candidateIndex < candidates.length, "Invalid candidate index.");
        Candidate memory candidate = candidates[candidateIndex];
        return (candidate.name, candidate.voteCount);
    }

    function getWinner() public onlyAfterVoting view returns (string memory winnerName) {
        uint winningVoteCount = 0;
        uint winnerIndex = 0;
        for (uint i = 0; i < candidates.length; i++) {
            if (candidates[i].voteCount > winningVoteCount) {
                winningVoteCount = candidates[i].voteCount;
                winnerIndex = i;
            }
        }
        winnerName = candidates[winnerIndex].name;
    }
}
