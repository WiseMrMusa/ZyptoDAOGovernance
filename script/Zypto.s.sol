// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/ZyptoVoteToken.sol";
import "../src/ZyptoGovernance.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorVotes.sol";

contract ZyptoLabTest is Script {
    ZyptoGovernance public zyptoGovernance;
    ZyptoVoteToken public zyptoVoteToken;

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        zyptoVoteToken = new ZyptoVoteToken();
        zyptoGovernance = new ZyptoGovernance(IVotes(address(zyptoVoteToken)));
    }
}