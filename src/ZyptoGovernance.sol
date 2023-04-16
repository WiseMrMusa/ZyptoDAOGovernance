// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/governance/Governor.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorCountingSimple.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorVotes.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorVotesQuorumFraction.sol";
import "./bunnz/ICO.sol";
import "./bunnz/launchPad.sol";

contract ZyptoGovernance is Governor, GovernorCountingSimple, GovernorVotes, GovernorVotesQuorumFraction {

    event BussinessCreated(
        uint256 indexed bussinessID,
        address indexed bussinessOwner,
        address ICOPlatform,
        address tokenAddress,
        uint256 deadline
    );
    constructor(IVotes _token)
        Governor("ZyptoGovernance")
        GovernorVotes(_token)
        GovernorVotesQuorumFraction(4)
    {}

    struct BussinessProposal {
        padICO platform;
        address bussinessOwner;
        IERC20 bussinessToken;
        uint256 startTime;
        uint256 endTime;
        bool soldOut;
        bool stopped;
    }

    uint256 bussinessID;
    mapping(uint256 => BussinessProposal) private _bussProposals;

    function fundBussiness(address _tokenAddress, string memory _projectName,string memory _description,uint256 _amountToRaise, uint256 _minETH,uint256 _totalSupply,uint256 _tokenPerMinETH,uint256 period) external onlyGovernance() {
        bussinessID = bussinessID + 1;
        BussinessProposal storage bussinessProposal = _bussProposals[bussinessID];
        bussinessProposal.bussinessOwner = _msgSender();
        bussinessProposal.startTime = block.timestamp;
        bussinessProposal.endTime = block.timestamp + period;
        bussinessProposal.platform = new padICO(_projectName,_description,_tokenAddress,_tokenPerMinETH,_amountToRaise,_totalSupply,_minETH);
        address[] memory t = new address[](1);
        t[0] = _tokenAddress;
        bussinessProposal.platform.connectToOtherContracts(t);
        bussinessProposal.platform.updatePriceForOneToken(_minETH);

        emit BussinessCreated(
            bussinessID,
            _msgSender(),
            address(bussinessProposal.platform),
            _tokenAddress,
            bussinessProposal.endTime
        );
    }

    function fundProject(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        string memory description
    ) external onlyGovernance() {
        propose(targets, values, calldatas, description);
    }

    // function fundProject(
    //     address[] memory targets,
    //     uint256[] memory values,
    //     bytes[] memory calldatas,
    //     string memory description
    // ) external onlyGovernance() {
    //     require(
    //         getVotes(_msgSender(), block.number - 1) >= proposalThreshold(),
    //         "Governor: proposer votes below proposal threshold"
    //     );

    //     uint256 proposalId = hashProposal(targets, values, calldatas, keccak256(bytes(description)));

    //     require(targets.length == values.length, "Governor: invalid proposal length");
    //     require(targets.length == calldatas.length, "Governor: invalid proposal length");
    //     require(targets.length > 0, "Governor: empty proposal");

    //     ProposalCore storage proposal = _proposals[proposalId];
    //     require(proposal.voteStart.isUnset(), "Governor: proposal already exists");

    //     uint64 snapshot = block.number.toUint64() + votingDelay().toUint64();
    //     uint64 deadline = snapshot + votingPeriod().toUint64();

    //     proposal.voteStart.setDeadline(snapshot);
    //     proposal.voteEnd.setDeadline(deadline);

    //     emit ProposalCreated(
    //         proposalId,
    //         _msgSender(),
    //         targets,
    //         values,
    //         new string[](targets.length),
    //         calldatas,
    //         snapshot,
    //         deadline,
    //         description
    //     );

    //     return proposalId;
    // }

    function votingDelay() public pure override returns (uint256) {
        return 1; // 1 block
    }

    function votingPeriod() public pure override returns (uint256) {
        return 120; // 2 minutes
    }

    function proposalThreshold() public pure override returns (uint256) {
        return 0;
    }

    // The following functions are overrides required by Solidity.

    function quorum(uint256 blockNumber)
        public
        view
        override(IGovernor, GovernorVotesQuorumFraction)
        returns (uint256)
    {
        return super.quorum(blockNumber);
    }
}