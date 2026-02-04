// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../src/Contract.sol";
import "forge-std/Script.sol";

contract DeployProjectRegistry is Script {
    function run() external {
        // read PRIVATE_KEY from env
        uint256 pk = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(pk);
        ProjectRegistry registry = new ProjectRegistry(vm.addr(pk));
        vm.stopBroadcast();

        console2.log("ProjectRegistry deployed at:", address(registry));
    }
}