// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

contract CounterV1{
    uint public num;

    function increment() public {
        num+=1;
    }
}

contract CounterV2{
    uint public num;

    function increment() public {
        num+=1;
    }

    function decrement() public {
        num-=1;
    }
}

contract Proxy {
    uint public num;
    bytes32 private constant IMPLEMENTATION_SLOT =bytes32(uint(keccak256("eip1967.proxy.implementation")) - 1);

    bytes32 private constant ADMIN_SLOT =bytes32(uint(keccak256("eip1967.proxy.admin")) - 1);

    constructor() {
        _setAdmin(msg.sender);
    }

    function upgradeTo(address _implementation) public {
        require(msg.sender==_getAdmin(),"Not authorized");
        _setImplementation(_implementation);
    }

    function delegate() public returns(bytes memory){
        (bool ok,bytes memory data)=_getImplementation().delegatecall(msg.data);
        require(ok,"delegatecall failed");
        return data;
    }

    fallback() external payable{
        delegate();
    }

    receive() external payable {
        delegate();
    }

    function _getAdmin() private view returns (address) {
        return StorageSlot.getAddressSlot(ADMIN_SLOT).value;
    }

    function _setAdmin(address _admin) private {
        require(_admin != address(0), "admin = zero address");
        StorageSlot.getAddressSlot(ADMIN_SLOT).value = _admin;
    }

    function _getImplementation() private view returns (address) {
        return StorageSlot.getAddressSlot(IMPLEMENTATION_SLOT).value;
    }

    function _setImplementation(address _implementation) private {
        require(_implementation.code.length > 0, "implementation is not contract");
        StorageSlot.getAddressSlot(IMPLEMENTATION_SLOT).value = _implementation;
    }
}

library StorageSlot{
    struct AddressSlot{
        address value;
    }

    function getAddressSlot(bytes32 slot) internal pure returns(AddressSlot storage r){
        assembly {
            r.slot:=slot
        }
    }
}
