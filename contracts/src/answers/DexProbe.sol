// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../levels/Dex.sol";

contract DexProbe {
    Dex public dex;
    
    constructor(address _dex) {
        dex = Dex(_dex);
    }
    
    function probeTokens() external view returns (address, address) {
        try dex.token1() returns (address t1) {
            try dex.token2() returns (address t2) {
                return (t1, t2);
            } catch {
                return (t1, address(0));
            }
        } catch {
            return (address(0), address(0));
        }
    }
    
    function probeOwner() external view returns (address) {
        try dex.owner() returns (address o) {
            return o;
        } catch {
            return address(0);
        }
    }
}