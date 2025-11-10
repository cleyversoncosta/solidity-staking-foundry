// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.30;

import "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

import "forge-std/Test.sol";
import "../src/StakingToken.sol";

contract StakingTokenTest is Test {
    StakingToken stakingToken;
    string name = "Staking Token";
    string symbol = "STK";
    address randomUser = vm.addr(1);

    function setUp() public {
        stakingToken = new StakingToken(name, symbol);
    }

    function testMintTokenCorrectly() public {

        vm.startPrank(randomUser);
        uint256 _amount = 1 ether;

        uint256 _balanceBefore = IERC20(address(stakingToken)).balanceOf(randomUser);

        stakingToken.mint(_amount);

        uint256 _balanceAfter = IERC20(address(stakingToken)).balanceOf(randomUser);

        assert(_balanceAfter - _balanceBefore == _amount);

        vm.stopPrank();
    }
}
