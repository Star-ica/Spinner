// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "forge-std/src/Script.sol";
import "../src/Counter.sol";

contract DeploySpinReward is Script {
    function run() external {
        address deployer = msg.sender;

        vm.startBroadcast(deployer);
        
        // Replace with your ERC20 token address
        address tokenAddress = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;

        SpinReward spinReward = new SpinReward(tokenAddress);

        console.log("SpinReward contract deployed at:", address(spinReward));
        vm.stopBroadcast();
    }
}
