// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "../src/Contract.sol";
import "forge-std/console.sol";
import {Script} from "forge-std/Script.sol";

contract CounterScript is Script {
    function run() external {
        // load private key from env (do NOT hardcode)
        uint256 privateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(privateKey);
        // pass admin address (here: msg.sender of tx)
        ProjectRegistry registry = new ProjectRegistry(vm.addr(privateKey));
        vm.stopBroadcast();
        console.log("ProjectRegistry deployed at:", address(registry));
    }
}
