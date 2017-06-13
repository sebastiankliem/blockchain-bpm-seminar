pragma solidity ^0.4.8;

contract BearingsExchange {
    string public name;
    address private manufacturerAddress;
    address private supplierAddress;
    address private nextSender;
    string private contractText;

    mapping(uint => function () external) transitions;

    event Initialized(string name, address manufacturerAddress, address supplierAddress);
    event ContractSent(address manufacturerAddress, address supplierAddress, string contractText);
    event ContractSigned();
    event PaymentRequested(address supplierAddress, uint amount);

    function BearingsExchange(address _manufacturerAddress, address _supplierAddress, string _contractText) {
        name = "BearingsExchange";
        manufacturerAddress = _manufacturerAddress;
        supplierAddress = _supplierAddress;
        nextSender = manufacturerAddress;
        contractText = _contractText;

        transitions[0] = this.sendContractStep;
    }

    function executeNext() {
        if (msg.sender == nextSender) {
            transitions[0]();
        }
    }

    function sendContract(bool isSend) {}

    function sendContractStep() {
        sendContract(true);
        ContractSent(manufacturerAddress, supplierAddress, contractText);
        nextSender = supplierAddress;
        transitions[0] = this.signContractStep;
    }

    function signContract(bool isSigned) {}

    function signContractStep() {
        signContract(true);
        ContractSigned();
        transitions[0] = this.sendPaymentStep;
    }

    function sendPaymentStep() {
        PaymentRequested(supplierAddress, 42);
    }
    
}