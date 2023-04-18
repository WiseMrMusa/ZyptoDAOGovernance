//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./interface/padStorage.sol";
import "./interface/IICO.sol";
import "./interface/IBunzz.sol";

contract padICO is padStorage, Ownable {
    event createdPad(
        string indexed projectName,
        string indexed description,
        uint256 indexed tokenPerMinETH,
        uint256 amountToRaise
    );
    event launched(
        address moderator,
        uint indexed duration,
        string indexed _tokenName
    );
    event stakeSuccessful(uint256 indexed amount, address indexed stakerName);
    event claimedSuccessfully(
        address indexed receiver,
        uint256 indexed claimAmount,
        address indexed padToken
    );
    event PriceForOneTokenChanged(address setter, uint256 price);
    event TokenAddressSet(address setter, address token);
    event Received(address, uint);

    constructor(
        string memory _projectName,
        string memory _description,
        address _tokenAddress,
        uint256 _tokenPerMinETH,
        uint256 _amountToRaise,
        uint256 _totalSupply,
        uint256 _minETH
    ) {
        moderator = msg.sender;
        minETH = _minETH;
        require(
            _tokenAddress != address(0),
            "tokenContract can't be address zero"
        );
        require(
            (((_tokenPerMinETH / minETH) * _amountToRaise) * 1e18 <=
                _totalSupply),
            "_total?Supply not enough for amountEthToRaise"
        );

        Pad({
            projectName: _projectName,
            description: _description,
            padOwner: msg.sender,
            tokenAddress: _tokenAddress,
            totalSupply: _totalSupply,
            tokenPerMinETH: _tokenPerMinETH,
            amountToRaise: _amountToRaise,
            duration: 0,
            startLaunch: false
        });

        emit createdPad(
            _projectName,
            _description,
            _tokenPerMinETH,
            _amountToRaise
        );
    }

    function createPad() public {}

    function connectToOtherContracts(
        address[] calldata _contracts
    ) external onlyOwner {
        setTokenAddress(_contracts[0]);
    }

    function setTokenAddress(address token) internal {
        Pad memory pad;
        require(
            pad.tokenAddress != token,
            "ICO: new token address is the same as the old one"
        );
        emit TokenAddressSet(msg.sender, token);
        pad.tokenAddress = token;
    }

    function updatePriceForOneToken(uint256 price) external onlyOwner {
        require(
            priceForOneToken != price,
            "ICO: new price is not different from the old price"
        );
        emit PriceForOneTokenChanged(msg.sender, price);
        priceForOneToken = price;
    }

    function launchPad(
        string memory _projectName,
        uint256 _period
    ) public onlyOwner {
        require(msg.sender == moderator, "Access denied");
        Pad memory pad;
        require(pad.startLaunch == false, "Pad already launched");
        bytes32 padNameInput = keccak256(abi.encodePacked(_projectName));
        bytes32 padName = keccak256(abi.encodePacked(pad.projectName));
        require(padName == padNameInput, "Invalid token name");
        IERC20(pad.tokenAddress).transferFrom(
            msg.sender,
            address(this),
            pad.totalSupply
        );
        uint256 period = block.timestamp + _period;
        pad.startLaunch = true;
        pad.duration = period;
        emit launched(moderator, period, _projectName);
    }

    function stakeOnPad() external payable {
        stakeOnPad_();
    }

    function stakeOnPad_() internal returns (bool) {
        Pad memory pad;
        require(pad.startLaunch == true, "Pad not available");
        require(block.timestamp < pad.duration, "LaunchPad Ended");
        require(msg.value >= minETH, "Insufficient Ethers");

        uint256 _amount = msg.value;
        
        amountBought[msg.sender] = _amount;

        emit stakeSuccessful(_amount, msg.sender);

        bool success = true;
        return success;
    }

    function claimLaunchPad(string memory _projectName) public {
        Pad memory pad;
        bytes32 padNameInput = keccak256(abi.encodePacked(_projectName));
        bytes32 padName = keccak256(abi.encodePacked(pad.projectName));
        require(padName == padNameInput, "Incorrect token name");
        if (block.timestamp >= pad.duration) {
            pad.startLaunch = false;
            launchPadExists[address(pad.tokenAddress)] == false;
        } else {
            revert("Launchpad duration not over");
        }
        uint256 _amountToClaim = amountBought[msg.sender];
        if (_amountToClaim == 0) revert("User did not stake on Launchpad");
        uint256 claimAmount = ((_amountToClaim / minETH) * pad.tokenPerMinETH) *
            1e18;
        bool transferSuccessful = IERC20(pad.tokenAddress).transfer(
            msg.sender,
            claimAmount
        );
        require(transferSuccessful, "transfer failed");
        amountBought[msg.sender] = 0;
        pad.totalSupply -= claimAmount;

        emit claimedSuccessfully(
            msg.sender,
            claimAmount,
            address(pad.tokenAddress)
        );
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function getTokenBalance(
        address _tokenContract
    ) public view returns (uint256) {
        return IERC20(_tokenContract).balanceOf(address(this));
    }

    function transferTokenBal(
        address _tokenContract,
        address _to,
        uint256 _amount
    ) public returns (bool success) {
        require(msg.sender == moderator, "Access denied");
        require(
            IERC20(_tokenContract).balanceOf(address(this)) >= _amount * 1e18,
            "Insufficient balance"
        );
        IERC20(_tokenContract).transfer(_to, _amount);
        success = true;
        return success;
    }

    function withdraw(
        address _to,
        uint256 _amount
    ) external returns (bool success) {
        require(msg.sender == moderator, "Access denied");
        require(address(this).balance >= _amount, "Insufficient balance");
        payable(_to).transfer(_amount);
        success = true;
        return success;
    }

    fallback() external payable {}

    receive() external payable {
        emit Received(msg.sender, msg.value);
    }
}
