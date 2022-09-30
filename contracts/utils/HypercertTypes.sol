// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

library HypercertTypes {
    struct Claim {
        bytes32 claimHash;
        uint64[2] workTimeframe;
        uint64[2] impactTimeframe;
        bytes32[] workScopes;
        bytes32[] impactScopes;
        bytes32[] rights;
        address[] contributors;
        uint256 totalUnits;
        uint16 version;
        bool exists;
        string name;
        string description;
        string URI;
    }
}
