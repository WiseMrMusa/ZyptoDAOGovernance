// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

contract ICOStorage {
    //address public Token;
    uint256 public priceForOneToken;

    uint256 projectStartTime;
    uint256 projectStopTime;
    uint256 amountToRaise;
    uint256 perTotalSale;

    address projectOwner;
    string projectName;
    string projectDescription;
    address tokenContractAddress;
    uint256 totalShare;
    uint256 value;

    address[] tokenHolders;
    mapping(address => bool) isTokenHolder;
    mapping(address => uint256) share;

}