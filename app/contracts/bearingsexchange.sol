pragma solidity ^0.4.8;

contract BearingsExchange {
    string public name;
    address private manufacturerAddress;
    address private supplierAddress;
    string private state;

    uint index;
    mapping(uint => function () external) transitions;

    event Initialized(string name, address manufacturerAddress, address supplierAddress);
    event SendContract(address manufacturerAddress, address supplierAddress);
    event ContractSent(address manufacturerAddress, address supplierAddress, string contractText);
    event ContractSigned(address manufacturerAddress, address supplierAddress, string contractText);
    event PaymentRequested(address supplierAddress, uint amount);

    function BearingsExchange(address _manufacturerAddress, address _supplierAddress, string _state) {
        name = "BearingsExchange";
        manufacturerAddress = _manufacturerAddress;
        supplierAddress = _supplierAddress;
        state = _state;

        index = 0;
        transitions[0] = this.notifyInitStep;
        transitions[1] = this.signContractStep;
        transitions[2] = this.sendPaymentStep;
    }

    function next() {
        index = index + 1;
        transitions[index]();
    }

    function notifyInitStep() {
        Initialized(name, manufacturerAddress, supplierAddress);
    }

    function signContractStep() {
        SendContract(manufacturerAddress, supplierAddress);
    }

    function sendContract(string contractText) {
        ContractSent(manufacturerAddress, supplierAddress, contractText);
    }

    function signContract(string contractText) {
        ContractSigned(manufacturerAddress, supplierAddress, contractText);
        next();
    }

    function sendPaymentStep() {
        PaymentRequested(supplierAddress, 42);
    }
    
}