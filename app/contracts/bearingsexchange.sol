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
    event ContractSigned(address supplierAddress);
    event PaymentReceived(address manufacturerAddress, uint paymentAmount);
    event PaymentOK();
    event PaymentRejected(uint difference);
    event BearingsProduced();
    event DifferenceRequested();

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
        ContractSigned(supplierAddress);
        nextSender = manufacturerAddress;
    }

    function receivePaymentStep(uint paymentAmount) {
        PaymentReceived(msg.sender, paymentAmount);
        nextSender = supplierAddress;
        if (paymentAmount > 50) {
            PaymentOK();
            transitions[0] = this.produceBearingsStep;
        }
        else {
            PaymentRejected(50 - paymentAmount);
            transitions[0] = this.requestDifferenceStep;
        }
    }

    function produceBearingsStep() {
        BearingsProduced();
    }

    function requestDifferenceStep() {
        DifferenceRequested();
    }
    
}