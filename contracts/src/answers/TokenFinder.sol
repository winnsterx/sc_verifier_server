// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TokenFinder {
    function scanForTokens(address dexAddress) external view returns (
        address token1,
        address token2,
        uint256 token1Balance,
        uint256 token2Balance,
        bool found
    ) {
        // Try to call token1() and token2() on the dex
        bytes memory token1Call = abi.encodeWithSignature("token1()");
        bytes memory token2Call = abi.encodeWithSignature("token2()");
        
        (bool success1, bytes memory data1) = dexAddress.staticcall(token1Call);
        (bool success2, bytes memory data2) = dexAddress.staticcall(token2Call);
        
        if (success1 && data1.length >= 32) {
            token1 = abi.decode(data1, (address));
        }
        
        if (success2 && data2.length >= 32) {
            token2 = abi.decode(data2, (address));
        }
        
        // Check balances if tokens are found
        if (token1 != address(0)) {
            (bool balSuccess, bytes memory balData) = token1.staticcall(
                abi.encodeWithSignature("balanceOf(address)", dexAddress)
            );
            if (balSuccess && balData.length >= 32) {
                token1Balance = abi.decode(balData, (uint256));
            }
        }
        
        if (token2 != address(0)) {
            (bool balSuccess, bytes memory balData) = token2.staticcall(
                abi.encodeWithSignature("balanceOf(address)", dexAddress)
            );
            if (balSuccess && balData.length >= 32) {
                token2Balance = abi.decode(balData, (uint256));
            }
        }
        
        found = (token1 != address(0) || token2 != address(0));
    }
    
    // Check addresses near the factory
    function checkNearbyAddresses(address start) external view returns (string memory) {
        // Convert address to uint256
        uint256 addrInt = uint256(uint160(start));
        
        string memory result = "";
        
        // Check next 10 addresses
        for (uint i = 1; i <= 10; i++) {
            address checkAddr = address(uint160(addrInt + i));
            uint256 codeSize;
            assembly {
                codeSize := extcodesize(checkAddr)
            }
            
            if (codeSize > 0) {
                // Found a contract
                result = string(abi.encodePacked(result, "Contract at +", uint2str(i), ": "));
                
                // Try to check if it's an ERC20
                (bool success, bytes memory data) = checkAddr.staticcall(
                    abi.encodeWithSignature("symbol()")
                );
                
                if (success && data.length > 0) {
                    result = string(abi.encodePacked(result, "Possible token;"));
                } else {
                    result = string(abi.encodePacked(result, "Unknown;"));
                }
            }
        }
        
        return result;
    }
    
    function uint2str(uint256 _i) internal pure returns (string memory str) {
        if (_i == 0) {
            return "0";
        }
        
        uint256 j = _i;
        uint256 len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        
        bytes memory bstr = new bytes(len);
        uint256 k = len;
        while (_i != 0) {
            k = k - 1;
            uint8 temp = (48 + uint8(_i - _i / 10 * 10));
            bstr[k] = bytes1(temp);
            _i /= 10;
        }
        
        return string(bstr);
    }
}