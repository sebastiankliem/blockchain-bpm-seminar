pragma solidity ^0.4.8;

contract BearingsExchange {
    string public name;
    address private manufacturerAddress;
    address private supplierAddress;
    string private state;

    mapping(uint => function () external) next;

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

        next[0] = this.notifyInitStep;
    }

    function next() {
        next[0]();
    }

    function notifyInitStep() {
        Initialized(name, manufacturerAddress, supplierAddress);
        next[0] = this.signContractStep;
    }

    function signContractStep() {
        SendContract(manufacturerAddress, supplierAddress);
        next[0] = this.sendPaymentStep;
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