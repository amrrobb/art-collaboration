// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {ArtCollaboration} from "../src/ArtCollaboration.sol";

contract DeployArtCollaboration is Script {
    function run() external returns (ArtCollaboration) {
        vm.startBroadcast();
        ArtCollaboration artCollab = new ArtCollaboration();
        vm.stopBroadcast();

        return artCollab;
    }
}
