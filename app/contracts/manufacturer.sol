pragma solidity ^0.4.8;
import "supplier.sol";

contract Manufacturer {
    string public name;

    event ContractSent(address supplierAddress, string data);
    event SignedContractReceived(address supplierAddress, string data);

    function Manufactruer(string _name) {
        name = _name;
    }

    function sendContract(address supplierAddress, string data) {
        Supplier s = Supplier(supplierAddress);
        s.receiveContract(this, data);
        ContractSent(supplierAddress, data);
    }

    function receiveSignedContract(address supplierAddress, string data) {
        SignedContractReceived(supplierAddress, data);
    }
}