// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

/// @title ManagerField
/// @notice Central registry for core DAO roles and authorities.
contract ManagerField {
    address public owner;

    // Role keys are simple bytes32 identifiers
    mapping(bytes32 => address) public roleAddress;

    event RoleUpdated(bytes32 indexed roleKey, address indexed oldAddress, address indexed newAddress);

    modifier onlyOwner() {
        require(msg.sender == owner, "ManagerField: not owner");
        _;
    }

    constructor(address _owner) {
        owner = _owner;
    }

    function setRole(bytes32 roleKey, address newAddress) external onlyOwner {
        address old = roleAddress[roleKey];
        roleAddress[roleKey] = newAddress;
        emit RoleUpdated(roleKey, old, newAddress);
    }

    function getRole(bytes32 roleKey) external view returns (address) {
        return roleAddress[roleKey];
    }
}
