pragma solidity ^0.6.0;

import "openzeppelin-contracts-06/proxy/Initializable.sol";

contract NewAttackerEngine is Initializable {
    address public upgrader;
    uint256 public horsePower;

    function initialize() external initializer {
        // Cannot overwrite existing initialization
    }

    function setZeroHorsePower() external {
        horsePower = 0;
    }

    // Required functions to maintain storage compatibility
    function _authorizeUpgrade() internal view {
        require(msg.sender == upgrader, "Can't upgrade");
    }

    function _setImplementation(address newImplementation) private {
        require(Address.isContract(newImplementation), "New implementation is not a contract");
        // Storage layout compatible with Motorbike
    }

    function upgradeToAndCall(address newImplementation, bytes memory data) external payable {
        _authorizeUpgrade();
        _upgradeToAndCall(newImplementation, data);
    }

    function _upgradeToAndCall(address newImplementation, bytes memory data) internal {
        _setImplementation(newImplementation);
        if (data.length > 0) {
            (bool success,) = newImplementation.delegatecall(data);
            require(success, "Call failed");
        }
    }
}