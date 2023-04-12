// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interface/IAirdropERC20.sol";
import "./interface/IBunzz.sol";

contract AirdropERC20 is Ownable, IBunzz, IAirdropERC20 {
    address public token;

    function connectToOtherContracts(address[] calldata contracts)
    external
    override(IAirdropERC20, IBunzz)
    onlyOwner
    {
        token = contracts[0];
    }

    function airdrop(address[] calldata recipients, uint256[] calldata amounts)
    external override
    onlyOwner
    {
        require(token != address(0), "Token have not been set");
        require(
            recipients.length == amounts.length,
            "Arrays must have the same length"
        );

      unchecked {
          for (uint256 i = 0; i < recipients.length; ++i) {
              IERC20(token).transfer(recipients[i], amounts[i]);
          }
      }
    }

    function retrieveTokens(uint256 amount) external override onlyOwner {
        require(token != address(0), "Token have not been set");

        require(
            IERC20(token).balanceOf(address(this)) >= amount,
            "Amount you wish to retrieve is bigger then actual balance"
        );

        IERC20(token).transfer(msg.sender, amount);
    }
}