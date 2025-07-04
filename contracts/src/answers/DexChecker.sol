// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IDex {
    function owner() external view returns (address);
    function token1() external view returns (address);
    function token2() external view returns (address);
}

contract DexChecker {
    function checkDexState(address dex) external view returns (address owner, address token1, address token2) {
        // Using low level calls to avoid reverts
        (bool s1, bytes memory d1) = dex.staticcall(abi.encodeWithSignature("owner()"));
        (bool s2, bytes memory d2) = dex.staticcall(abi.encodeWithSignature("token1()"));
        (bool s3, bytes memory d3) = dex.staticcall(abi.encodeWithSignature("token2()"));
        
        if (s1 && d1.length >= 32) owner = abi.decode(d1, (address));
        if (s2 && d2.length >= 32) token1 = abi.decode(d2, (address));
        if (s3 && d3.length >= 32) token2 = abi.decode(d3, (address));
    }
}