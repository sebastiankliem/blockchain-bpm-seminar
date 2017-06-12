pragma solidity ^0.4.8;

contract BearingsExchange {
    string public name;
    string public state;
    address private manufacturerAddress;
    address private supplierAddress;

    event ContractSent(address manufacturerAddress, address supplierAddress, string contractText);
    event SignedContractReceived(address supplierAddress, string data);

    function BearingsExchange(address _manufacturerAddress, address _supplierAddress, string _state) {
        name = "BearingsExchange";
        state = _state;
        manufacturerAddress = _manufacturerAddress;
        supplierAddress = _supplierAddress;
    }

    function sendContract(string contractText) {
        ContractSent(manufacturerAddress, supplierAddress, contractText);
    }

    function receiveSignedContract(address supplierAddress, string data) {
        SignedContractReceived(supplierAddress, data);
    }
}