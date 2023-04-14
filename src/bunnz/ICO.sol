// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./interface/ICOStorage.sol";
import "./interface/IICO.sol";
import "./interface/IBunzz.sol";

contract ICO is ICOStorage, IICO, Ownable, IBunzz{

    using SafeMath for uint256;

    event PriceForOneTokenChanged(address setter, uint256 price);
    event TokenAddressSet(address setter, address token);
    event TokenBought(address buyer, uint256 amount);
    event Deposit(address, uint256);


    constructor(
        address _tokenAddress,
        uint256 _totalTokenShare,
        uint256 _projectEndTime,
        string memory _projectName,
        string memory _description,
        address _owner
    ) {
        projectOwner = _owner;
        projectName = _projectName;
        projectDescription = _description;
        projectStartTime = block.timestamp;
        projectStopTime = block.timestamp + _projectEndTime;

        totalShare = _totalTokenShare;
        tokenContractAddress = _tokenAddress;
    }


    function connectToOtherContracts(address[] calldata _contracts) external override onlyOwner{
        setTokenAddress(_contracts[0]);
    }

    function setTokenAddress(address token) internal {
        require(Token!=token, "ICO: new token address is the same as the old one");
        emit TokenAddressSet(msg.sender, token);
        Token = token;
    }

    function depositNativeToken() public payable {
        //require msg.value is greater than 0;
        require(msg.value > 0, "Eth must be greater than 0");
        ensureProjectHasStarted();
        ensureProjectHasNotEnded();
        if(!isTokenHolder[msg.sender]){
            isTokenHolder[msg.sender] = true;
            tokenHolders.push(msg.sender);
        }
        value += msg.value;
        share[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    
    function queryShare() public view returns(uint256) {
        return share[msg.sender];
    }

    function queryName() public view returns(string memory){
        return projectName;
    }

    function queryDescription() public view returns(string memory){
        return projectDescription;
    }


    

    function claimToken() public{
        ensureIsTokenHolder();
        ensureProjectHasEnded();
        uint256 myToken = (share[msg.sender] * totalShare) / value;
        IERC20(tokenContractAddress).transfer(msg.sender,myToken);
    }

    function withDrawValue() public{
        ensureIsProjectOwner();
        ensureProjectHasEnded();
        (bool success,) = payable(projectOwner).call{value: 45 }("");
        if(!success) revert("Failed");
    }

    function ensureProjectHasStarted() internal view{
        if(block.timestamp < projectStartTime) revert("Project has not started!");
    }
    function ensureProjectHasNotEnded() internal view{
        if(block.timestamp > projectStopTime) revert("Project has ended!");
    }

    function ensureProjectHasEnded() internal view {
        if(block.timestamp < projectStopTime) revert("Project is still on!");
    }

    function ensureIsTokenHolder() internal view {
        if (isTokenHolder[msg.sender] != true) revert("You are not a token holder");
    }

    function ensureIsProjectOwner() internal view {
        if (msg.sender != projectOwner) revert("You are not authorized for this");
    }
}