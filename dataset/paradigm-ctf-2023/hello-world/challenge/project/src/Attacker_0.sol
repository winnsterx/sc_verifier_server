pragma solidity ^0.8.0;

interface IChallenge {
    function TARGET() external view returns (address);
}

contract Attacker {
    constructor(address challengeAddress) payable {
        IChallenge challenge = IChallenge(challengeAddress);
        address target = challenge.TARGET();
        // The challenge expects 1 wei to be sent to the TARGET address.
        // The constructor is payable, and we can pass value when deploying.
        // This will send 1 wei from the attacker contract to the TARGET.
        // Using call instead of transfer for robustness, though transfer should also work for 1 wei.
        (bool success, ) = payable(target).call{value: 1}("");
        require(success, "Transfer failed");
    }
}