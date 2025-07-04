// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IDex {
    function token1() external view returns (address);
    function token2() external view returns (address);
    function owner() external view returns (address);
}

contract DexHelper {
    function getDexInfo(address dex) external view returns (
        address owner,
        address token1,
        address token2,
        bool hasTokens
    ) {
        IDex dexContract = IDex(dex);
        
        // Try to get owner
        try dexContract.owner() returns (address _owner) {
            owner = _owner;
        } catch {
            owner = address(0);
        }
        
        // Try to get token addresses
        try dexContract.token1() returns (address _token1) {
            token1 = _token1;
            hasTokens = true;
        } catch {
            token1 = address(0);
            hasTokens = false;
        }
        
        try dexContract.token2() returns (address _token2) {
            token2 = _token2;
        } catch {
            token2 = address(0);
        }
    }
}