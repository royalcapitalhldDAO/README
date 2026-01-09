// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

/// @title Royal Capital Holdings DAO LLC
/// @notice Authored governance vessel for collective decision-making,
///         treasury management, and contract execution.
/// @dev Extended with treasury issuance rules.

contract RoyalCapitalDAO {
    address public founder;
    mapping(address => bool) public members;
    uint256 public treasuryBalance;

    struct Proposal {
        uint256 id;
        address proposer;
        string description;
        uint256 votesFor;
        uint256 votesAgainst;
        bool executed;
        address payable target;   // recipient of funds
        uint256 amount;           // amount to issue
    }

    mapping(uint256 => Proposal) public proposals;
    uint256 public nextProposalId;

    event MemberAdded(address member);
    event ProposalCreated(uint256 id, address proposer, string description, address target, uint256 amount);
    event Voted(uint256 id, address voter, bool support);
    event ProposalExecuted(uint256 id, address target, uint256 amount);

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
    function createProposal(
        string calldata _description,
        address payable _target,
        uint256 _amount
    ) external {
        require(members[msg.sender], "Only members can propose");
        require(_amount <= treasuryBalance, "Insufficient treasury balance");

        proposals[nextProposalId] = Proposal({
            id: nextProposalId,
            proposer: msg.sender,
            description: _description,
            votesFor: 0,
            votesAgainst: 0,
            executed: false,
            target: _target,
            amount: _amount
        });

        emit ProposalCreated(nextProposalId, msg.sender, _description, _target, _amount);
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
        require(proposal.amount <= treasuryBalance, "Insufficient treasury");

        proposal.executed = true;
        treasuryBalance -= proposal.amount;
        (bool success, ) = proposal.target.call{value: proposal.amount}("");
        require(success, "Transfer failed");

        emit ProposalExecuted(_proposalId, proposal.target, proposal.amount);
    }
}// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

/// @title Royal Capital Holdings DAO LLC
/// @notice Authored governance vessel for collective decision-making,
///         treasury management, assurance, and contract execution.
/// @dev Extended with treasury issuance + assurance rules.

contract RoyalCapitalDAO {
    address public founder;
    mapping(address => bool) public members;
    uint256 public treasuryBalance;

    struct Proposal {
        uint256 id;
        address proposer;
        string description;
        uint256 votesFor;
        uint256 votesAgainst;
        bool executed;
        address payable target;
        uint256 amount;
        address assurer;     // member who assures proposal
        bool assured;        // assurance status
    }

    mapping(uint256 => Proposal) public proposals;
    uint256 public nextProposalId;

    event MemberAdded(address member);
    event ProposalCreated(uint256 id, address proposer, string description, address target, uint256 amount);
    event Voted(uint256 id, address voter, bool support);
    event Assured(uint256 id, address assurer);
    event ProposalExecuted(uint256 id, address target, uint256 amount);

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
    function createProposal(
        string calldata _description,
        address payable _target,
        uint256 _amount
    ) external {
        require(members[msg.sender], "Only members can propose");
        require(_amount <= treasuryBalance, "Insufficient treasury balance");

        proposals[nextProposalId] = Proposal({
            id: nextProposalId,
            proposer: msg.sender,
            description: _description,
            votesFor: 0,
            votesAgainst: 0,
            executed: false,
            target: _target,
            amount: _amount,
            assurer: address(0),
            assured: false
        });

        emit ProposalCreated(nextProposalId, msg.sender, _description, _target, _amount);
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

    // -------------------------
    // Assurance
    // -------------------------
    function assureProposal(uint256 _proposalId) external {
        require(members[msg.sender], "Only members can assure");
        Proposal storage proposal = proposals[_proposalId];
        require(!proposal.executed, "Proposal already executed");
        require(!proposal.assured, "Already assured");

        proposal.assurer = msg.sender;
        proposal.assured = true;

        emit Assured(_proposalId, msg.sender);
    }

    // -------------------------
    // Execution
    // -------------------------
    function executeProposal(uint256 _proposalId) external {
        Proposal storage proposal = proposals[_proposalId];
        require(!proposal.executed, "Already executed");
        require(proposal.votesFor > proposal.votesAgainst, "Proposal not approved");
        require(proposal.assured, "Proposal must be assured");
        require(proposal.amount <= treasuryBalance, "Insufficient treasury");

        proposal.executed = true;
        treasuryBalance -= proposal.amount;
        (bool success, ) = proposal.target.call{value: proposal.amount}("");
        require(success, "Transfer failed");

        emit ProposalExecuted(_proposalId, proposal.target, proposal.amount);
    }
}npx hardhat compile
