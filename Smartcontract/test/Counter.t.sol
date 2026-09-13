// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "forge-std/src/Test.sol";
import "../src/Counter.sol";
import "../src/mocks/ERC20Mock.sol";

contract SpinRewardTest is Test {
    SpinReward public spinReward;
    ERC20Mock public token;

    address public owner;
    address public user;

    function setUp() public {
        owner = address(this);
        user = address(0x123);

        token = new ERC20Mock("MockToken", "MTK", 18);
        spinReward = new SpinReward(address(token));

        // Mint tokens to the user and owner
        token.mint(user, 1000 ether);
        token.mint(owner, 1000 ether);

        // Approve contract to handle user tokens
        vm.prank(user);
        token.approve(address(spinReward), 1000 ether);
        token.approve(address(spinReward), 1000 ether);
    }

    function testFundAndStake() public {
        vm.prank(user);
        spinReward.fund(100 ether);

        uint256 userBalance = spinReward.balances(user);
        assertEq(userBalance, 100 ether, "User balance should be 100 ether");

        vm.prank(user);
        spinReward.stake(50 ether);

        userBalance = spinReward.balances(user);
        assertEq(userBalance, 50 ether, "User balance should be reduced after staking");
    }

    function testRewardCalculation() public {
        vm.prank(user);
        spinReward.fund(200 ether);

        vm.prank(user);
        spinReward.processSpinResult(100 ether, "2");

        uint256 userBalance = spinReward.balances(user);
        assertEq(userBalance, 202 ether, "User balance should include stake and 2% reward");
    }

    function testOwnerAddFunds() public {
        spinReward.addFundsToContract(500 ether);

        uint256 contractBalance = spinReward.contractBalance();
        assertEq(contractBalance, 500 ether, "Contract balance should be updated");
    }

    function testWithdrawWithFee() public {
        vm.prank(user);
        spinReward.fund(100 ether);

        vm.prank(user);
        spinReward.withdraw(50 ether);

        uint256 userBalance = spinReward.balances(user);
        uint256 contractBalance = spinReward.contractBalance();

        assertEq(userBalance, 48 ether, "User balance should reflect 2% fee deduction");
        assertEq(contractBalance, 2 ether, "Contract balance should reflect fee");
    }
}
