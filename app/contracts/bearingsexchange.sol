pragma solidity ^0.4.8;

contract BearingsExchange {
    string public name;
    uint private fine;
    address private manufacturerAddress;
    address private supplierAddress;
    address private nextSender;
    string private contractText;

    function () internal nextTransaction;

    event Initialized(string name, address manufacturerAddress, address supplierAddress);
    event ContractSent(address manufacturerAddress, address supplierAddress, string contractText);
    event ContractSigned(address supplierAddress);
    event PaymentReceived(address manufacturerAddress);
    event BearingsSent();
    event ConfirmationSent();
    event FineRequestSent(uint fine);
    event CancellationSent();

    function BearingsExchange(address _manufacturerAddress, address _supplierAddress, string _contractText) {
        name = "BearingsExchange";
        manufacturerAddress = _manufacturerAddress;
        supplierAddress = _supplierAddress;
        nextSender = manufacturerAddress;
        contractText = _contractText;

        nextTransaction = sendContractStep;
    }

    function executeNext() {
        if (msg.sender == nextSender) {
            nextTransaction();
        }
    }

    function setFine(uint _fine) external {
        fine = _fine;
    }

    function sendContractStep() internal {
        //sendTransaction("Contract send!")
        ContractSent(manufacturerAddress, supplierAddress, contractText);
        nextSender = supplierAddress;
        nextTransaction = signContractStep;
    }

    function signContractStep() internal {
        //sendTransaction("Contract signed!")
        ContractSigned(supplierAddress);
        nextSender = manufacturerAddress;
        nextTransaction = receivePaymentStep;
    }

    function receivePaymentStep() internal {
        PaymentReceived(msg.sender);
        nextSender = supplierAddress;
        nextTransaction = sendBearingsStep;
    }

    function sendBearingsStep() internal {
        BearingsSent();
        nextSender = manufacturerAddress;
        nextTransaction = fineDecision1;
    }

    function fineDecision1() internal {
        if (fine == 0) {
            nextTransaction = confirmationStep;
        }
        else {
            nextTransaction = requestFineStep;
        }
        nextSender = manufacturerAddress;
        executeNext();
    }

    function confirmationStep() internal {
        ConfirmationSent();
        selfdestruct(manufacturerAddress);
    }

    function requestFineStep() internal {
        FineRequestSent(fine);
        nextSender = supplierAddress;
        nextTransaction = fineDecision2;
    }

    function fineDecision2() internal {
        if (fine < 100) {
            nextTransaction = confirmationStep;
        }
        else {
            nextTransaction = cancelContractStep;
        }
        nextSender = supplierAddress;
        executeNext();
    }

    function cancelContractStep() internal {
        CancellationSent();
    }

    // function requestDifferenceStep() internal {
    //     DifferenceRequested();
    // }

    /* 
    * Activity attributes: ID, Preconditions, Event, nextSender, nextStep
    * Gateway attributes: Preconditions, (Decisions), nextSender
    */
}