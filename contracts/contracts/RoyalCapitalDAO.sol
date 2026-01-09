// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

/// @title Royal Capital Holdings DAO LLC
/// @notice Authored governance vessel for collective decision-making,
///         treasury management, and contract execution.
/// @dev This contract is a simplified DAO framework, expandable with modules.

contract RoyalCapitalDAO {
    // -------------------------
    // State Variables
    // -------------------------
    address public founder;              // Original deployer
    mapping(address => bool) public members; // DAO members
    uint256 public treasuryBalance;      // DAO treasury balance

    struct Proposal {
        uint256 id;
        address proposer;
        string description;
        uint256 votesFor;
        uint256 votesAgainst;
        bool executed;
    }

    mapping(uint256 => Proposal) public proposals;
    uint256 public nextProposalId;

    // -------------------------
    // Events
    // -------------------------
    event MemberAdded(address member);
    event ProposalCreated(uint256 id, address proposer, string description);
    event Voted(uint256 id, address voter, bool support);
    event ProposalExecuted(uint256 id);

    // -------------------------
    // Constructor
    // -------------------------
    constructor() {
        founder = msg.sender;
        members[msg.sender] = true;
    }

    // -------------------------
    // Membership
    // -------------------------
    function addMember(address _member) external {
        require(msg.sender == founder, "Only founder can add members");
        members[_member] = true;
        emit MemberAdded(_member);
    }

    // -------------------------
    // Treasury
    // -------------------------
    receive() external payable {
        treasuryBalance += msg.value;
    }

    function getTreasuryBalance() external view returns (uint256) {
        return treasuryBalance;
    }

    // -------------------------
    // Governance
    // -------------------------
    function createProposal(string calldata _description) external {
        require(members[msg.sender], "Only members can propose");
        proposals[nextProposalId] = Proposal({
            id: nextProposalId,
            proposer: msg.sender,
            description: _description,
            votesFor: 0,
            votesAgainst: 0,
            executed: false
        });
        emit ProposalCreated(nextProposalId, msg.sender, _description);
        nextProposalId++;
    }

    function vote(uint256 _proposalId, bool support) external {
        require(members[msg.sender], "Only members can vote");
        Proposal storage proposal = proposals[_proposalId];
        require(!proposal.executed, "Proposal already executed");

        if (support) {
            proposal.votesFor++;
        } else {
            proposal.votesAgainst++;
        }

        emit Voted(_proposalId, msg.sender, support);
    }

    function executeProposal(uint256 _proposalId) external {
        Proposal storage proposal = proposals[_proposalId];
        require(!proposal.executed, "Already executed");
        require(proposal.votesFor > proposal.votesAgainst, "Proposal not approved");

        proposal.executed = true;
        emit ProposalExecuted(_proposalId);
    }npx hardhat compile
}
