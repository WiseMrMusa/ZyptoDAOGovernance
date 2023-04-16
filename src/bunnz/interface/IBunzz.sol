// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

interface IBunzz {
    function connectToOtherContracts(address[] calldata _contracts) external;
}