// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

/// @title Royal Capital Holdings DAO LLC Governance Contract
/// @notice Executable governance vessel for proposals, voting, and authorized execution.
contract RoyalCapitalDAO {
    /// @dev Core roles — wired to POLICY_FOR_ISSUANCE and COMPLIANCE_INDEX.
    address public daoManager;          // ManagerField: ultimate administrative authority
    address public complianceOfficer;   // Ensures on-chain actions align with COMPLIANCE_INDEX
    address public treasury;            // Contract or multisig holding DAO funds

    uint256 public proposalCount;

    enum ProposalType {
        GENERAL,        // Generic governance
        ISSUANCE,       // Token / unit issuance (must respect POLICY_FOR_ISSUANCE)
        TREASURY,       // Treasury movements
        PARAMETER,      // Config changes
        SETTLEMENT      // XRP / external settlement acknowledgements
    }

    enum ProposalStatus {
        ACTIVE,
        EXECUTED,
        CANCELLED
    }

    struct Proposal {
        uint256 id;
        address proposer;
        ProposalType proposalType;
        string referenceURI;      // Off-chain ref: POLICY_FOR_ISSUANCE, COMPLIANCE_INDEX, etc.
        bytes callData;           // Encoded function call for execution
        address target;           // Target contract to call
        uint256 startBlock;
        uint256 endBlock;
        uint256 forVotes;
        uint256 againstVotes;
        ProposalStatus status;
    }

    mapping(uint256 => Proposal) public proposals;
    mapping(uint256 => mapping(address => bool)) public hasVoted;

    event ProposalCreated(
        uint256 indexed id,
        address indexed proposer,
        ProposalType proposalType,
        string referenceURI
    );

    event VoteCast(
        uint256 indexed id,
        address indexed voter,
        bool support,
        uint256 weight
    );

    event ProposalExecuted(uint256 indexed id);
    event ProposalCancelled(uint256 indexed id);

    modifier onlyManager() {
        require(msg.sender == daoManager, "Not daoManager");
        _;
    }

    modifier onlyComplianceOfficer() {
        require(msg.sender == complianceOfficer, "Not complianceOfficer");
        _;
    }

    constructor(
        address _daoManager,
        address _complianceOfficer,
        address _treasury
    ) {
        daoManager = _daoManager;
        complianceOfficer = _complianceOfficer;
        treasury = _treasury;
    }

    /// @notice Create a new proposal. Reference URI must point to governing policy / compliance records.
    function createProposal(
        ProposalType _proposalType,
        string calldata _referenceURI,
        address _target,
        bytes calldata _callData,
        uint256 _votingPeriodBlocks
    ) external returns (uint256) {
        require(_votingPeriodBlocks > 0, "Invalid voting period");

        uint256 id = ++proposalCount;

        proposals[id] = Proposal({
            id: id,
            proposer: msg.sender,
            proposalType: _proposalType,
            referenceURI: _referenceURI,
            callData: _callData,
            target: _target,
            startBlock: block.number,
            endBlock: block.number + _votingPeriodBlocks,
            forVotes: 0,
            againstVotes: 0,
            status: ProposalStatus.ACTIVE
        });

        emit ProposalCreated(id, msg.sender, _proposalType, _referenceURI);
        return id;
    }

    /// @notice Voting logic is left abstract — you can wire in token voting, delegate voting, etc.
    function _votingWeight(address voter
