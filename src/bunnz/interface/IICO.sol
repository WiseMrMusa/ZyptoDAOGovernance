// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

interface IICO {
    function updatePriceForOneToken(uint256 price) external;

    function depositNativeToken() external payable;

    function queryShare() external view returns (uint256);

    function queryName() external view returns (string memory);

    function queryDescription() external view returns (string memory);

    function claimToken() external;

    function withDrawValue() external;
}
