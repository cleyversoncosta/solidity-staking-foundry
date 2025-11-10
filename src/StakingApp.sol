// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.30;

import "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract StakingApp is Ownable {
    address public stakingToken;
    uint256 public stakingPeriod;
    uint256 public fixedStakingAmount;
    uint256 public rewardPerPeriod;

    mapping(address => uint256) public userBalance;
    mapping(address => uint256) public elapsePeriod;

    event ChangeStakingPeriod(uint256 newStakingPeriod);
    event DepositTokens(address userAddress, uint256 tokenAmountToDeposit);
    event WithdrawTokens(address userAddress, uint256 tokenAmountToWithdraw);
    event EtherSet(uint256 amount);

    constructor(
        address _stakingToken,
        address _owner,
        uint256 _stakingPeriod,
        uint256 _fixedStakingAmount,
        uint256 _rewardPerPeriod
    ) Ownable(_owner) {
        stakingToken = _stakingToken;
        stakingPeriod = _stakingPeriod;
        fixedStakingAmount = _fixedStakingAmount;
        rewardPerPeriod = _rewardPerPeriod;
    }

    function depositTokens(uint256 _tokenAmountToDeposit) external {
        require(_tokenAmountToDeposit > 0, "Need to send more than 0");
        require(
            _tokenAmountToDeposit == fixedStakingAmount,
            string("Only fixedStakingAmount tokens at a time")
        );
        require(
            userBalance[msg.sender] + _tokenAmountToDeposit <=
                fixedStakingAmount,
            "Deposit greater than fixed amount"
        );

        bool success = IERC20(stakingToken).transferFrom(
            msg.sender,
            address(this),
            _tokenAmountToDeposit
        );
        userBalance[msg.sender] += _tokenAmountToDeposit;

        require(success, "Transfer failed");

        elapsePeriod[msg.sender] = block.timestamp;
        
        emit DepositTokens(msg.sender, _tokenAmountToDeposit);
    }

    function withdraw() external {
        uint256 _balance = userBalance[msg.sender];

        userBalance[msg.sender] = 0;
        bool success = IERC20(stakingToken).transfer(msg.sender, _balance);

        require(success, "Transfer failed");

        emit WithdrawTokens(msg.sender, _balance);
    }

    function claimRewards() external {
        require(userBalance[msg.sender] > 0, "Not staking");

        uint256 elapsedPeriod = block.timestamp - elapsePeriod[msg.sender];
        require(elapsedPeriod > stakingPeriod, "Need to wait");

        elapsePeriod[msg.sender] = block.timestamp;

        (bool success, ) = msg.sender.call{value: rewardPerPeriod}("");

        require(success, "Transfer failed");
    }

    receive() external payable onlyOwner {
        emit EtherSet(msg.value);
    }

    function changeStakingPeriod(uint256 _stakingPeriod) public onlyOwner {
        stakingPeriod = _stakingPeriod;

        emit ChangeStakingPeriod(_stakingPeriod);
    }
}
