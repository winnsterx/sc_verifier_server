pragma solidity ^0.8.0;

contract DoubleEntryPoint {

    // Vulnerability exploit
    // Target is the player needing to interact with the detection bot and re-entry in delegateTransfer.

    uint256 private constant MAX_UINT = type(uint256).max;

    address public immutable vault;

    // The vault can call the double entrypoint's sweepToken if the detection bot is triggered.

    // constructor sets the DEP's delegatedFrom and other variables.

    constructor(address _vault) {
        vault = _vault;
    }

    // Not sure about further functions. 

    // The main idea is to deploy the detection bot and set it.

    // The actual attack is done through functions on existing contracts.
}
