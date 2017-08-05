pragma solidity ^0.4.8;

contract BearingsExchange {
    string public name;
    uint private fine;
    address private manufacturerAddress;
    address private supplierAddress;
    address private nextSender;
    string private contractText;

    function () internal nextTransition;

    event Initialized(string name, address manufacturerAddress, address supplierAddress);
    event ContractSent(address manufacturerAddress, address supplierAddress, string contractText);
    event ContractSigned(address supplierAddress);
    event PaymentReceived(address manufacturerAddress);
    event BearingsSent();
    event ConfirmationSent();
    event FineRequestSent(uint fine);
    event CancellationSent();
    event ProcessFinished();

    function BearingsExchange(address _manufacturerAddress, address _supplierAddress, string _contractText) {
        name = "BearingsExchange";
        manufacturerAddress = _manufacturerAddress;
        supplierAddress = _supplierAddress;
        nextSender = manufacturerAddress;
        contractText = _contractText;

        nextTransition = sendContractStep;
    }

    function executeNext() {
        if (msg.sender == nextSender) {
            nextTransition();
        }
    }

    function setFine(uint _fine) external {
        fine = _fine;
    }

    function sendContractStep() internal {
        //sendTransaction("Contract send!")
        ContractSent(manufacturerAddress, supplierAddress, contractText);
        nextSender = supplierAddress;
        nextTransition = signContractStep;
    }

    function signContractStep() internal {
        //sendTransaction("Contract signed!")
        ContractSigned(supplierAddress);
        nextSender = manufacturerAddress;
        nextTransition = receivePaymentStep;
    }

    function receivePaymentStep() internal {
        PaymentReceived(msg.sender);
        nextSender = supplierAddress;
        nextTransition = sendBearingsStep;
    }

    function sendBearingsStep() internal {
        BearingsSent();
        nextSender = manufacturerAddress;
        nextTransition = fineDecision1;
    }

    function fineDecision1() internal {
        if (fine == 0) {
            nextTransition = confirmationStep;
        }
        else {
            nextTransition = requestFineStep;
        }
        nextSender = manufacturerAddress;
        executeNext();
    }

    function confirmationStep() internal {
        ConfirmationSent();
        nextTransition = processFinishedStep;
        executeNext();
    }

    function requestFineStep() internal {
        FineRequestSent(fine);
        nextSender = supplierAddress;
        nextTransition = fineDecision2;
    }

    function fineDecision2() internal {
        if (fine < 100) {
            nextTransition = confirmationStep;
        }
        else {
            nextTransition = cancelContractStep;
        }
        nextSender = supplierAddress;
        executeNext();
    }

    function cancelContractStep() internal {
        CancellationSent();
        nextTransition = processFinishedStep;
        executeNext();
    }

    function processFinishedStep() internal {
        ProcessFinished();
        selfdestruct(manufacturerAddress);
    }

    // function requestDifferenceStep() internal {
    //     DifferenceRequested();
    // }

    /* 
    * Activity attributes: ID, Preconditions, Event, nextSender, nextStep
    * Gateway attributes: Preconditions, (Decisions), nextSender
    */
}