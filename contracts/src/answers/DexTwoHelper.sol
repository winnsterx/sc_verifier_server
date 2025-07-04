// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../levels/DexTwo.sol";

contract DexTwoHelper {
    
    DexTwo public dexTwo;
    
    constructor(address _dexTwo) {
        dexTwo = DexTwo(_dexTwo);
    }
    
    function getTokenAddresses() public view returns (address token1, address token2, bool areSet) {
        try dexTwo.token1() returns (address t1) {
            token1 = t1;
            try dexTwo.token2() returns (address t2) {
                token2 = t2;
                areSet = (t1 != address(0) || t2 != address(0));
            } catch {
                areSet = false;
            }
        } catch {
            areSet = false;
        }
    }
    
    function getOwner() public view returns (address) {
        return dexTwo.owner();
    }
}