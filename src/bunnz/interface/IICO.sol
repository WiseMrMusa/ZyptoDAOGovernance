// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

interface IICO{

    function depositNativeToken() external payable;

    function queryShare() external view returns(uint256);

    function queryName() external view returns(string memory);

    function queryDescription() external view returns(string memory);

    function claimToken() external;
    
    function withDrawValue() external;




}   