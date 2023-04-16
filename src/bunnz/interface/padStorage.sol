// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

contract padStorage {
    //address public Token;
    uint256 public priceForOneToken;

    struct Pad {
        
        string projectName;
        string description;
        address padOwner;
        address tokenAddress;
        uint totalSupply;
        uint256 tokenPerMinETH;
        uint256 amountToRaise;
        uint duration;
        bool startLaunch;
    }
    uint256 public minETH;

    address moderator;
    //mapping(uint256 => bool) idUsed;
    //mapping(uint256 => Pad) padIds;
    mapping(address => bool) launchPadExists;
    mapping(address => uint256) amountBought;

    uint256[] padIDs;

}