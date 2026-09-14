// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "forge-std/src/Script.sol";
import "../src/spinner.sol";

contract Deploy is Script {
    function run() external {
        address deployer = msg.sender;

        vm.startBroadcast(deployer);
        
        // Replace with your ERC20 token address
        address tokenAddress = 0x75edC9335175Fc0552D51D48439F229c10420fe3;

        SpinReward spinReward = new SpinReward(tokenAddress);

        console.log("SpinReward contract deployed at:", address(spinReward));
        vm.stopBroadcast();
    }
}
