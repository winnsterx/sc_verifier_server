pragma solidity <0.7.0;

import "openzeppelin-contracts-06/proxy/Initializable.sol";

contract AttackerEngine is Initializable {
    address public upgrader;
    uint256 public horsePower;

    function initialize() external initializer {
        horsePower = 0;
    }

    function setZeroHorsePowerAndUpgrader() external {
        horsePower = 0;
        upgrader = msg.sender;
    }

    function _authorizeUpgrade() internal view {
        require(msg.sender == upgrader, "Can't upgrade");
    }

    function _setImplementation(address newImplementation) private {
        // Storage layout compatibility functions
    }

    function upgradeToAndCall(address newImplementation, bytes memory data) external payable {
        _authorizeUpgrade();
        _upgradeToAndCall(newImplementation, data);
    }

    function _upgradeToAndCall(address newImplementation, bytes memory data) private {
        _setImplementation(newImplementation);
        if (data.length > 0) {
            (bool success,) = newImplementation.delegatecall(data);
            require(success, "Call failed");
        }
    }
}