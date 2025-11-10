// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.30;

import "forge-std/Test.sol";
import "../src/StakingToken.sol";
import "../src/StakingApp.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract StakingAppTest is Test {
    StakingToken stakingToken;
    StakingApp stakingApp;

    // Staking token
    string name = "Staking Token";
    string symbol = "STK";

    // Staking App
    address owner = vm.addr(1);
    uint256 stakingPeriod = 10000000;
    uint fixedStakingAmount = 10;
    uint rewardPerPeriod = 1 ether;
    address randomUser = vm.addr(2);
    uint256 rewardPerPeriod_ = 1 ether;
    uint256 stakingPeriod_ = 100000000000000;

    function setUp() external {
        stakingToken = new StakingToken(name, symbol);
        stakingApp = new StakingApp(
            address(stakingToken),
            owner,
            stakingPeriod,
            fixedStakingAmount,
            rewardPerPeriod
        );
    }

    function testStakingTokenCorrectDeployed() external view {
        assert(address(stakingToken) != address(0));
    }

    function testStakingAppCorrectDeployed() external view {
        assert(address(stakingApp) != address(0));
    }

    function testShouldRevertNotOwner() external {
        uint256 newStakingPeriod = 1;

        vm.expectRevert();
        stakingApp.changeStakingPeriod(newStakingPeriod);
    }

    function testShouldChangeStakingPeriod() external {
        uint256 newStakingPeriod = 1;

        vm.startPrank(owner);

        uint256 stakingPeriodBefore = stakingApp.stakingPeriod();

        stakingApp.changeStakingPeriod(newStakingPeriod);

        uint256 stakingPerioAfter = stakingApp.stakingPeriod();

        assert(stakingPeriodBefore != newStakingPeriod);
        assert(stakingPerioAfter == newStakingPeriod);
        vm.stopPrank();
    }

    function testContractEtherReceive() external {
        vm.startPrank(owner);
        uint256 etherValue = 1 ether;

        vm.deal(owner, etherValue);

        uint256 balanceBefore = address(stakingApp).balance;

        (bool success, ) = address(stakingApp).call{value: etherValue}("");

        uint256 balanceAfter = address(stakingApp).balance;

        assert(balanceAfter - balanceBefore == etherValue);

        vm.stopPrank();
    }

    function testIncorrectDepositAmountZeroShouldRevert() external {
        vm.startPrank(owner);

        uint256 depositAmount = 0;

        vm.expectRevert("Need to send more than 0");
        stakingApp.depositTokens(depositAmount);

        vm.stopPrank();
    }

    function testIncorrectDepositAmountShouldRevert() external {
        vm.startPrank(owner);

        uint256 depositAmount = 1;

        vm.expectRevert("Only fixedStakingAmount tokens at a time");
        stakingApp.depositTokens(depositAmount);

        vm.stopPrank();
    }

    function testDepositTokensCorrectly() external {
        vm.startPrank(randomUser);

        uint256 tokenAmount = stakingApp.fixedStakingAmount();
        stakingToken.mint(tokenAmount);

        uint256 userBalanceBefore = stakingApp.userBalance(randomUser);
        uint256 eleapsedPeriodBefore = stakingApp.elapsePeriod(randomUser);

        IERC20(stakingToken).approve(address(stakingApp), tokenAmount);
        stakingApp.depositTokens(tokenAmount);

        uint256 userBalanceAfter = stakingApp.userBalance(randomUser);
        uint256 eleapsedPeriodAfter = stakingApp.elapsePeriod(randomUser);

        assert(userBalanceAfter - userBalanceBefore == tokenAmount);
        assert(eleapsedPeriodBefore == 0);
        assert(eleapsedPeriodAfter == block.timestamp);
        vm.stopPrank();
    }

    function testCanNotClaimIfNotStaking() external {
        vm.startPrank(randomUser);

        vm.expectRevert("Not staking");
        stakingApp.claimRewards();

        vm.stopPrank();
    }

    function testCanNotClaimIfNotElapsedTime() external {
        vm.startPrank(randomUser);

        uint256 tokenAmount = stakingApp.fixedStakingAmount();
        stakingToken.mint(tokenAmount);

        uint256 userBalanceBefore = stakingApp.userBalance(randomUser);
        uint256 elapsePeriodBefore = stakingApp.elapsePeriod(randomUser);
        IERC20(stakingToken).approve(address(stakingApp), tokenAmount);
        stakingApp.depositTokens(tokenAmount);
        uint256 userBalanceAfter = stakingApp.userBalance(randomUser);
        uint256 elapsePeriodAfter = stakingApp.elapsePeriod(randomUser);

        assert(userBalanceAfter - userBalanceBefore == tokenAmount);
        assert(elapsePeriodBefore == 0);
        assert(elapsePeriodAfter == block.timestamp);

        vm.expectRevert("Need to wait");
        stakingApp.claimRewards();

        vm.stopPrank();
    }

    function testShouldRevertIfNoEther() external {
        vm.startPrank(randomUser);

        uint256 tokenAmount = stakingApp.fixedStakingAmount();
        stakingToken.mint(tokenAmount);

        uint256 userBalanceBefore = stakingApp.userBalance(randomUser);
        uint256 elapsePeriodBefore = stakingApp.elapsePeriod(randomUser);
        IERC20(stakingToken).approve(address(stakingApp), tokenAmount);
        stakingApp.depositTokens(tokenAmount);
        uint256 userBalanceAfter = stakingApp.userBalance(randomUser);
        uint256 elapsePeriodAfter = stakingApp.elapsePeriod(randomUser);

        assert(userBalanceAfter - userBalanceBefore == tokenAmount);
        assert(elapsePeriodBefore == 0);
        assert(elapsePeriodAfter == block.timestamp);

        vm.warp(block.timestamp + stakingPeriod_);
        vm.expectRevert("Transfer failed");
        stakingApp.claimRewards();

        vm.stopPrank();
    }

    function testCanClaimRewardsCorrectly() external {
        vm.startPrank(randomUser);

        uint256 tokenAmount = stakingApp.fixedStakingAmount();
        stakingToken.mint(tokenAmount);

        uint256 userBalanceBefore = stakingApp.userBalance(randomUser);
        uint256 elapsePeriodBefore = stakingApp.elapsePeriod(randomUser);
        IERC20(stakingToken).approve(address(stakingApp), tokenAmount);
        stakingApp.depositTokens(tokenAmount);
        uint256 userBalanceAfter = stakingApp.userBalance(randomUser);
        uint256 elapsePeriodAfter = stakingApp.elapsePeriod(randomUser);

        assert(userBalanceAfter - userBalanceBefore == tokenAmount);
        assert(elapsePeriodBefore == 0);
        assert(elapsePeriodAfter == block.timestamp);
        vm.stopPrank();

        vm.startPrank(owner);
        uint256 etherAmount = 100000 ether;
        vm.deal(owner, etherAmount);
        (bool success, ) = address(stakingApp).call{value: etherAmount}("");
        require(success, "Test transfer failed");
        vm.stopPrank();

        vm.startPrank(randomUser);
        vm.warp(block.timestamp + stakingPeriod_);
        uint256 etherAmountBefore = address(randomUser).balance;
        stakingApp.claimRewards();
        uint256 etherAmountAfter = address(randomUser).balance;
        uint256 elapsedPeriod = stakingApp.elapsePeriod(randomUser);

        assert(etherAmountAfter - etherAmountBefore == rewardPerPeriod_);
        assert(elapsedPeriod == block.timestamp);

        vm.stopPrank();
    }


    // Withdraw Function Tests

    function testCanOnlyWithdraw0WithoutDeposit() external {
        vm.startPrank(randomUser);

        uint256 userBalanceBefore = stakingApp.userBalance(randomUser);
        stakingApp.withdraw();
        uint256 userBalanceAfter = stakingApp.userBalance(randomUser);

        assert(userBalanceAfter == userBalanceBefore);

        vm.stopPrank();
    }

    function testWithdrawTokensCorrectly() external {
        vm.startPrank(randomUser);

        uint256 tokenAmount = stakingApp.fixedStakingAmount();
        stakingToken.mint(tokenAmount);

        uint256 userBalanceBefore = stakingApp.userBalance(randomUser);
        uint256 elapsePeriodBefore = stakingApp.elapsePeriod(randomUser);
        IERC20(stakingToken).approve(address(stakingApp), tokenAmount);
        stakingApp.depositTokens(tokenAmount);
        uint256 userBalanceAfter = stakingApp.userBalance(randomUser);
        uint256 elapsePeriodAfter = stakingApp.elapsePeriod(randomUser);

        assert(userBalanceAfter - userBalanceBefore == tokenAmount);
        assert(elapsePeriodBefore == 0);
        assert(elapsePeriodAfter == block.timestamp);

        uint256 userBalanceBefore2 = IERC20(stakingToken).balanceOf(randomUser);
        uint256 userBalanceInMapping = stakingApp.userBalance(randomUser);
        stakingApp.withdraw();
        uint256 userBalanceAfter2 = IERC20(stakingToken).balanceOf(randomUser);

        assert(userBalanceAfter2 == userBalanceBefore2 + userBalanceInMapping);

        vm.stopPrank();
    }

}
