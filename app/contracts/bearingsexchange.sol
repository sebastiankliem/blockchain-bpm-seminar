pragma solidity ^0.4.8;

contract BearingsExchange {
    string public name;
    uint private fine;
    address private manufacturerAddress;
    address private supplierAddress;
    address private nextSender;
    string private contractText;

    mapping(uint => function () internal) transitions;

    event Initialized(string name, address manufacturerAddress, address supplierAddress);
    event ContractSent(address manufacturerAddress, address supplierAddress, string contractText);
    event ContractSigned(address supplierAddress);
    event PaymentReceived(address manufacturerAddress);
    event BearingsSent();

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

    function setFine(uint _fine) external {
        fine = _fine;
    }

    function sendContractStep() internal {
        //sendTransaction("Contract send!")
        ContractSent(manufacturerAddress, supplierAddress, contractText);
        nextSender = supplierAddress;
        transitions[0] = signContractStep;
    }

    function signContractStep() internal {
        //sendTransaction("Contract signed!")
        ContractSigned(supplierAddress);
        nextSender = manufacturerAddress;
        transitions[0] = receivePaymentStep;
    }

    function receivePaymentStep() internal {
        PaymentReceived(msg.sender);
        nextSender = supplierAddress;
        transitions[0] = sendBearingsStep;
    }

    function sendBearingsStep() internal {
        BearingsSent();
        nextSender = manufacturerAddress;
        transitions[0] = fineDecision1;
    }

    function fineDecision1() internal {
        if (fine == 0) {
            transitions[0] = confirmationStep;
        }
        else {
            transitions[0] = requestFineStep;
        }
        nextSender = manufacturerAddress;
        executeNext();
    }

    function confirmationStep() internal {

    }

    function requestFineStep() internal {

    }

    // function requestDifferenceStep() internal {
    //     DifferenceRequested();
    // }

    /* 
    * Activity attributes: ID, Preconditions, Event, nextSender, nextStep
    * Gateway attributes: Preconditions, (Decisions), nextSender
    */
}