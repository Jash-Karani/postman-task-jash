// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract DecentralizedVoting is Ownable {
    struct Candidate {
        string name;
        uint256 voteCount;
    }

    mapping(uint256 => Candidate) public candidates;
    mapping(address => bool) public hasVoted;

    uint256 public totalVotes;
    uint256 public candidateCount;

    IERC20 public electionToken;

    event VoteCast(address indexed voter, uint256 candidateId);

    constructor(address _tokenAddress) {
        electionToken = IERC20(_tokenAddress);
    }

    function setCandidateList(string[] memory _candidateNames) external onlyOwner {
        require(_candidateNames.length > 0, "Candidate list cannot be empty");
        candidateCount = _candidateNames.length;
        
        for (uint256 i = 0; i < candidateCount; i++) {
            candidates[i] = Candidate({
                name: _candidateNames[i],
                voteCount: 0
            });
        }
    }

    function castVote(uint256 _candidateId) external {
        require(_candidateId < candidateCount, "Invalid candidate ID");
        require(!hasVoted[msg.sender], "You have already voted");

        electionToken.transferFrom(msg.sender, address(this), 1);

        candidates[_candidateId].voteCount++;
        totalVotes++;
        hasVoted[msg.sender] = true;

        emit VoteCast(msg.sender, _candidateId);
    }

    function viewResults() external view returns (uint256[] memory) {
        uint256[] memory voteCounts = new uint256[](candidateCount);
        for (uint256 i = 0; i < candidateCount; i++) {
            voteCounts[i] = candidates[i].voteCount;
        }
        return voteCounts;
    }

    function determineWinner() external view returns (string memory) {
        require(totalVotes > 0, "No votes cast yet");

        uint256 maxVotes = 0;
        uint256 winningCandidateId = 0;

        for (uint256 i = 0; i < candidateCount; i++) {
            if (candidates[i].voteCount > maxVotes) {
                maxVotes = candidates[i].voteCount;
                winningCandidateId = i;
            }
        }

        return candidates[winningCandidateId].name;
    }
}
