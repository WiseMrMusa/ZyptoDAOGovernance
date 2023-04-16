// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/ZyptoVoteToken.sol";
import "../src/ZyptoGovernance.sol";
import "../src/bunnz/mockToken.sol";

import "@openzeppelin/contracts/governance/extensions/GovernorVotes.sol";


contract ZyptoLabTest is Test {
    ZyptoGovernance public zyptoGovernance;
    ZyptoVoteToken public zyptoVoteToken;
    mockToken public mock;

    function setUp() public {
        vm.startPrank(address(0x10));
        zyptoVoteToken = new ZyptoVoteToken();
        zyptoGovernance = new ZyptoGovernance(IVotes(address(zyptoVoteToken)));
        vm.stopPrank();
        vm.startPrank(address(0x20));
        mock = new mockToken("Zyper", "ZYP");
        mock.mint(400);
        vm.stopPrank();
    }

    function test_1_BuyToken() public {
        vm.startPrank(address(0x10));
        zyptoVoteToken.mint(msg.sender,100 ether);
        assertEq(zyptoVoteToken.balanceOf(msg.sender),100 ether);
        vm.stopPrank();
    }
    function testPropose() public {
       vm.startPrank(address(0x10));
       vm.deal(address(0x10), 1000);
       address[] memory targets = new address[](1);
       targets[0] = address(zyptoGovernance);
       uint256[] memory values = new uint256[](1);
       values[0] = 0;
       bytes[] memory calldatas = new bytes[](1);
       calldatas[0]  = abi.encodeWithSignature("transfer(address,uint256)", address(zyptoGovernance), 10);
       string memory description = "My name might not be the same";
       zyptoGovernance.propose(targets, values, calldatas, description);
       vm.stopPrank();

    }

    // function testFundBussiness() public {
    //     vm.startPrank(address(0x20));
    //     vm.deal(address(0x20), 1000);
    //     zyptoGovernance.fundBussiness(address(mock), "getEquity", "fundraising for Companies", 120, 1000, 400,1, 300);

    // }

}