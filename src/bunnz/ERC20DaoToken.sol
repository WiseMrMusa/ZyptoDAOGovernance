// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

// Uncomment this line to use console.log
// import "hardhat/console.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC20Pausable} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Pausable.sol";
import {ERC20Snapshot} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Snapshot.sol";
import {IERC20DAOToken} from "./interface/IERC20DAOToken.sol";

contract ERC20DAOToken is
  Ownable,
  ERC20,
  ERC20Pausable,
  ERC20Snapshot,
  IERC20DAOToken
{
  event AuthorizedSnapshotter(address account);
  event DeauthorizedSnapshotter(address account);

  // Mapping which stores all addresses allowwed to snapshot
  mapping(address => bool) public authorizedToSnapshot;

  uint8 private _decimals;

  constructor(
    string memory name,
    string memory symbol,
    uint8 decimals_
  ) ERC20(name, symbol) {
    _decimals = decimals_;
  }

  function decimals() public view override returns (uint8) {
    return _decimals;
  }

  /**
   * Mints new tokens.
   * @param account the account to mint the tokens for
   * @param amount the amount of tokens to mint.
   */
  function mint(address account, uint256 amount) external onlyOwner {
    _mint(account, amount);
  }

  /**
   * Burns tokens from an address.
   * @param account the account to burn the tokens for
   * @param amount the amount of tokens to burn.
   */
  function burn(address account, uint256 amount) external onlyOwner {
    _burn(account, amount);
  }

  /**
   * Pauses the token contract preventing any token mint/transfer/burn operations.
   * Can only be called if the contract is unpaused.
   */
  function pause() external onlyOwner {
    _pause();
  }

  /**
   * Unpauses the token contract preventing any token mint/transfer/burn operations
   * Can only be called if the contract is paused.
   */
  function unpause() external onlyOwner {
    _unpause();
  }

  function getCurrentSnapshotId() external view returns (uint256) {
    return _getCurrentSnapshotId();
  }

  /**
   * Creates a token balance snapshot. Ideally this would be called by the
   * controlling DAO whenever a proposal is made.
   */
  function snapshot() external override returns (uint256) {
    require(
      authorizedToSnapshot[_msgSender()] || _msgSender() == owner(),
      "Not authorized to snapshot"
    );
    return _snapshot();
  }

  /**
   * Authorizes an account to take snapshots
   * @param account The account to authorize
   */
  function authorizeSnapshotter(address account) external onlyOwner {
    require(!authorizedToSnapshot[account], "Account already authorized");

    authorizedToSnapshot[account] = true;
    emit AuthorizedSnapshotter(account);
  }

  /**
   * Deauthorizes an account to take snapshots
   * @param account The account to de-authorize
   */
  function deauthorizeSnapshotter(address account) external onlyOwner {
    require(authorizedToSnapshot[account], "Account not authorized");

    authorizedToSnapshot[account] = false;
    emit DeauthorizedSnapshotter(account);
  }

  /**
   * Utility function to transfer tokens to many addresses at once.
   * @param recipients The addresses to send tokens to
   * @param amount The amount of tokens to send
   * @return Boolean if the transfer was a success
   */
  function transferBulk(address[] calldata recipients, uint256 amount)
    external
    returns (bool)
  {
    address sender = _msgSender();

    uint256 total = amount * recipients.length;
    require(
      balanceOf(sender) >= total,
      "ERC20: transfer amount exceeds balance"
    );

    require(!paused(), "ERC20Pausable: token transfer while paused");

    for (uint256 i = 0; i < recipients.length; ++i) {
      address recipient = recipients[i];
      require(recipient != address(0), "ERC20: transfer to the zero address");

      _transfer(sender, recipient, amount);
    }

    return true;
  }

  function _beforeTokenTransfer(
    address from,
    address to,
    uint256 amount
  )
    internal
    virtual
    override(ERC20Pausable, ERC20Snapshot, ERC20)
    whenNotPaused
  {
    super._beforeTokenTransfer(from, to, amount);
  }
}