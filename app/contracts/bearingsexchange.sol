pragma solidity ^0.4.8;

contract BearingsExchange {
    string public name;
    uint private amount;
    address private manufacturerAddress;
    address private supplierAddress;
    address private nextSender;
    string private contractText;

    mapping(uint => function () internal) transitions;

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

        transitions[0] = sendContractStep;
    }

    function executeNext() {
        if (msg.sender == nextSender) {
            transitions[0]();
        }
    }

    function setAmount(uint _amount) {
        amount = _amount;
    }

    function sendContract(bool isSend) internal {}

    function sendContractStep() internal {
        sendContract(true);
        ContractSent(manufacturerAddress, supplierAddress, contractText);
        nextSender = supplierAddress;
        transitions[0] = signContractStep;
    }

    function signContract(bool isSigned) internal {}

    function signContractStep() internal {
        signContract(true);
        ContractSigned(supplierAddress);
        nextSender = manufacturerAddress;
    }

    function receivePaymentStep() internal {
        PaymentReceived(msg.sender, amount);
        nextSender = supplierAddress;
        if (amount > 50) {
            PaymentOK();
            transitions[0] = produceBearingsStep;
        }
        else {
            PaymentRejected(50 - amount);
            transitions[0] = requestDifferenceStep;
        }
    }

    function produceBearingsStep() internal {
        BearingsProduced();
    }

    function requestDifferenceStep() internal {
        DifferenceRequested();
    }
    
}