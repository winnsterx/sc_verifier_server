pragma solidity ^0.8.0;

contract GasDrainer {

    fallback() external payable {
        while (true) {
            new EmptyContract();
        }
    }

    contract EmptyContract {
        constructor() payable {
            // Consume gas with contract creation
        }
    }
}