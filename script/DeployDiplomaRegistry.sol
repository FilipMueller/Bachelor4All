// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../src/DiplomaRegistry.sol";
import "forge-std/Script.sol";

contract DeployDiplomaRegistry is Script {
    function run() external {
        uint256 pk = vm.envUint("PRIVATE_KEY");

        address issuer = vm.addr(pk);

        vm.startBroadcast(pk);
        DiplomaRegistry registry = new DiplomaRegistry(issuer);
        vm.stopBroadcast();

        console2.log("DiplomaRegistry deployed at:", address(registry));
        console2.log("Issuer address:", issuer);
    }
}
