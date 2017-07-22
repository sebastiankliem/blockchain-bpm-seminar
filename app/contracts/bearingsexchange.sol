pragma solidity ^0.4.11;

contract BearingsExchange {
    uint constant minimumGas = 100000;

    mapping(uint => address) participants;
    
    //Mapping for branching purposes
    mapping(uint => bool) stepDone;

    int[] public transitionIds;
    mapping (uint => Transition) transitions;

    struct Transition {
        uint previousId;
        address nextSender;
        function () internal func;
    }
    
    // string public name;
    // uint private fine;
    // address private participants[0];
    // address private participants[1];
    // address private nextSender;
    // string private contractText;

    // function () internal nextTransition;

    // Decision logic attributes
    event Initialized(string name, address participants[0], address participants[1]);
    event ContractSent(address participants[0], address participants[1], string contractText);
    event ContractSigned(address participants[1]);
    event PaymentReceived(address participants[0]);
    event BearingsSent();
    event ConfirmationSent();
    event FineRequestSent(uint fine);
    event CancellationSent();
    event ProcessFinished();

    uint public lastStep;

    function BearingsExchange(address _participant0, address _participant1) {
        participants[0] = _participant0;
        participants[1] = _participant1;

        createTransitions();

        lastStep = 42;  // an arbitrary high number
        stepDone[42] = true;
        transitionIds.push(0);
    }

    function createTransitions() {
        transitions[0] = Transition(42, participants[0], sendContractStep);
        transitions[1] = Transition(0, participants[0], step1);
        transitions[2] = Transition(1, participants[0], gate0);
        transitions[3] = Transition(1, participants[0], step2);
        transitions[4] = Transition(1, participants[1], stepNonExistent);
        transitions[5] = Transition(2, participants[0], step3);
        transitions[6] = Transition(3, participants[0], gate1);
        transitions[7] = Transition(3, participants[1], step5);
        transitions[8] = Transition(3, participants[1], step6);
        transitions[9] = Transition(4, participants[0], stepNonExistent);
        transitions[10] = Transition(5, participants[0], gate2);
        transitions[11] = Transition(6, participants[1], gate2);
        transitions[12] = Transition(5, participants[0], step7);
    }

    modifier only(address participant) {
        require(msg.sender == participant);
        _;
    }

    modifier whenDone(uint stepId) {
        require(stepDone[stepId]);
        _;
    }

    modifier executeNextIfEnoughGas() {
    _;
    if (msg.gas > minimumGas) {
        GasLeft(msg.gas);
        executeNext(msg.sender);
    } else {
        NotEnoughGas(msg.gas, minimumGas);
    }
    
    event ExecuteNext();
    event TransitionE(uint previousId, address nextSender);
    function executeNext(address sender) {
        ExecuteNext();
        GasLeft(msg.gas);
        for (var index = 0; index < transitionIds.length; index++) {
            var tran = transitions[transitionIds[index]];
            TransitionE(tran.previousId, tran.nextSender);
            if (sender == tran.nextSender && stepDone[tran.previousId]) {
                if (msg.gas > minimumGas) {
                    GasLeft(msg.gas);
                    removeTransition(index);
                    tran.func();
                } else {
                    NotEnoughGas(msg.gas, minimumGas);
                }
                GasLeft(msg.gas);
            }
        }
    }

    function setFine(uint _fine) external {
        fine = _fine;
    }

    function sendContractStep() executeNextIfEnoughGas() {
        DoSendContract()
        transitionIds.push(1);
    }

    function signContractStep() internal {
        ContractSigned(participants[1]);
        nextSender = participants[0];
        nextTransition = receivePaymentStep;
    }

    function receivePaymentStep() internal {
        PaymentReceived(msg.sender);
        nextSender = participants[1];
        nextTransition = sendBearingsStep;
    }

    function sendBearingsStep() internal {
        BearingsSent();
        nextSender = participants[0];
        nextTransition = fineDecision1;
    }

    function fineDecision1() internal {
        if (fine == 0) {
            nextTransition = confirmationStep;
        }
        else {
            nextTransition = requestFineStep;
        }
        nextSender = participants[0];
        executeNext();
    }

    function confirmationStep() internal {
        ConfirmationSent();
        nextTransition = processFinishedStep;
        executeNext();
    }

    function requestFineStep() internal {
        FineRequestSent(fine);
        nextSender = participants[1];
        nextTransition = fineDecision2;
    }

    function fineDecision2() internal {
        if (fine < 100) {
            nextTransition = confirmationStep;
        }
        else {
            nextTransition = cancelContractStep;
        }
        nextSender = participants[1];
        executeNext();
    }

    function cancelContractStep() internal {
        CancellationSent();
        nextTransition = processFinishedStep;
        executeNext();
    }

    function processFinishedStep() internal {
        ProcessFinished();
        selfdestruct(participants[0]);
    }
}