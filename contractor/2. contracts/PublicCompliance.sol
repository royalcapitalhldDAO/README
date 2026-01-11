// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

/// @title PublicCompliance
/// @notice Public on-chain mirror of COMPLIANCE_INDEX and POLICY_FOR_ISSUANCE posture.
contract PublicCompliance {
    address public owner;

    // Canonical URIs into GitHub
    string public complianceIndexURI;
    string public policyForIssuanceURI;
    string public settlementIndexURI;

    event ComplianceIndexURIUpdated(string newURI);
    event PolicyForIssuanceURIUpdated(string newURI);
    event SettlementIndexURIUpdated(string newURI);

    modifier onlyOwner() {
        require(msg.sender == owner, "PublicCompliance: not owner");
        _;
    }

    constructor(
        address _owner,
        string memory _complianceIndexURI,
        string memory _policyForIssuanceURI,
        string memory _settlementIndexURI
    ) {
        owner = _owner;
        complianceIndexURI = _complianceIndexURI;
        policyForIssuanceURI = _policyForIssuanceURI;
        settlementIndexURI = _settlementIndexURI;
    }

    function updateComplianceIndexURI(string calldata _newURI) external onlyOwner {
        complianceIndexURI = _newURI;
        emit ComplianceIndexURIUpdated(_newURI);
    }

    function updatePolicyForIssuanceURI(string calldata _newURI) external onlyOwner {
        policyForIssuanceURI = _newURI;
        emit PolicyForIssuanceURIUpdated(_newURI);
    }

    function updateSettlementIndexURI(string calldata _newURI) external onlyOwner {
        settlementIndexURI = _newURI;
        emit SettlementIndexURIUpdated(_newURI);
    }
}
