// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

/// @title RoyalCapitalDAOIdentifier
/// @notice Immutable(ish) identifier anchoring the DAO's public record.
contract RoyalCapitalDAOIdentifier {
    string public constant NAME = "Royal Capital Holdings DAO LLC";
    string public constant PURPOSE =
        "Authored governance vessel for collective decision-making, treasury management, and contract execution.";

    string public repositoryURI;
    string public recordKeepingIndexURI;
    string public complianceIndexURI;

    uint256 public immutable chainId;
    uint256 public immutable deployedAtBlock;
    address public immutable deployedBy;

    event RepositoryURIUpdated(string newURI);
    event RecordKeepingIndexURIUpdated(string newURI);
    event ComplianceIndexURIUpdated(string newURI);

    modifier onlyDeployer() {
        require(msg.sender == deployedBy, "Not deployer");
        _;
    }

    constructor(
        string memory _repositoryURI,
        string memory _recordKeepingIndexURI,
        string memory _complianceIndexURI
    ) {
        repositoryURI = _repositoryURI;
        recordKeepingIndexURI = _recordKeepingIndexURI;
        complianceIndexURI = _complianceIndexURI;

        deployedAtBlock = block.number;
        deployedBy = msg.sender;

        uint256 id;
        assembly {
            id := chainid()
        }
        chainId = id;
    }

    function updateRepositoryURI(string calldata _newURI) external onlyDeployer {
        repositoryURI = _newURI;
        emit RepositoryURIUpdated(_newURI);
    }

    function updateRecordKeepingIndexURI(string calldata _newURI) external onlyDeployer {
        recordKeepingIndexURI = _newURI;
        emit RecordKeepingIndexURIUpdated(_newURI);
    }

    function updateComplianceIndexURI(string calldata _newURI) external onlyDeployer {
        complianceIndexURI = _newURI;
        emit ComplianceIndexURIUpdated(_newURI);
    }
}
