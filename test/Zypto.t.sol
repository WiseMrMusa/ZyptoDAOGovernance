// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/ZyptoVoteToken.sol";
import "../src/ZyptoGovernance.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorVotes.sol";

contract ZyptoLabTest is Test {
    ZyptoGovernance public zyptoGovernance;
    ZyptoVoteToken public zyptoVoteToken;

    function setUp() public {
        vm.startPrank(address(0x10));
        zyptoVoteToken = new ZyptoVoteToken();
        zyptoGovernance = new ZyptoGovernance(IVotes(address(zyptoVoteToken)));
        vm.stopPrank();
    }

    function test_1_BuyToken() public {
        vm.startPrank(address(0x10));
        zyptoVoteToken.mint(msg.sender,100 ether);
        assertEq(zyptoVoteToken.balanceOf(msg.sender),100 ether);
        vm.stopPrank();
    }
}
