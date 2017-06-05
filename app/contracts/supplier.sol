pragma solidity ^0.4.8;
import "manufacturer.sol";

contract Supplier {
    string public name;

    event ContractReceived(address manufacturerAddress, string data);
    event SignedContractSent(address manufacturerAddress, string data);

    function Supplier(string _name) {
        name = _name;
    }

    function receiveContract(address manufacturerAddress, string data) {
        ContractReceived(manufacturerAddress, data);
    }

    function signContract(address manufacturerAddress, string data) {
        Manufacturer m = Manufacturer(manufacturerAddress);
        m.receiveSignedContract(this, data);
        SignedContractSent(manufacturerAddress, data);
    }
}