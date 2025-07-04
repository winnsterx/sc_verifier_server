pragma solidity ^0.8.0;

interface ISimpleToken {
    function name() external view returns (string memory);
    function destroy(address payable _to) external;
}

contract TargetTokenRecovery {
    address private target;


    constructor(address _recovery) {
        // Calculate first SimpleToken address (nonce=1 in standard create address)
        // Formula: keccak256(RecoveryInstance . i)
        // Note: i starts from 0 for initial token creation via generateToken
        bytes memory noncePacked = hex'01';
        assembly {
            let p := mload(0x40)
            mstore(0x00, _recovery)
            mstore(0x20, mload(noncePacked))
            target := keccak256(0x00, 0x40)
        }
    }

    function findTokenAddress() public view returns (address) {
        return target;
    }

    function sendEth() external payable {
        // Send ETH to token contract to receive tokens via receive()
        (bool success,) = target.call{value: msg.value}(new bytes(32));
        require(success, "ETH transfer failed");
    }

    function destroyToken() external {
        // Destroy token contract and send balance to_recovery
        ISimpleToken(target).destroy(payable(address(0xa16E02E87b7454126E5E10d957A927A7F5B5d2be)));
    }
}
