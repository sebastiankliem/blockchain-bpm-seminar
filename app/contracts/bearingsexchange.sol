pragma solidity ^0.4.11;

contract BearingsExchange {
    uint constant minimumGas = 100000;

    mapping(uint => address) participants;
    
    //Mapping for branching purposes
    mapping(uint => bool) stepDone;

    uint[] public transitionIds;
    mapping (uint => Transition) transitions;

    struct Transition {
        uint previousId;
        address nextSender;
        function () internal func;
    }

    event GasLeft(uint amount);

    function BearingsExchange(address _participant0, address _participant1) {
        participants[0] = _participant0;
        participants[1] = _participant1;

        createTransitions();

        stepDone[0] = true;
        transitionIds.push(1);
    }

    function createTransitions() {
        transitions[1]  = Transition(0,  participants[0], sendContractStep);
        transitions[2]  = Transition(1,  participants[1], signContractStep);
        transitions[3]  = Transition(2,  participants[0], paymentStep);
        transitions[4]  = Transition(3,  participants[1], receivePaymentStep);
        transitions[5]  = Transition(4,  participants[1], sendBearingsStep);
        transitions[6]  = Transition(5,  participants[0], analyseBearingsStep);
        transitions[7]  = Transition(6,  participants[0], fineDecision1);
        transitions[8]  = Transition(7,  participants[0], confirmationStep);
        transitions[9]  = Transition(7,  participants[0], requestFineStep);
        transitions[10] = Transition(9,  participants[0], fineDecision2);
        transitions[11] = Transition(10, participants[0], cancelContractStep);
        transitions[12] = Transition(8,  participants[0], processConfirmedFinishedStep);
        transitions[13] = Transition(11, participants[0], processCanceledFinishedStep);
    }

    modifier only(address participant) {
        require(msg.sender == participant);
        _;
    }

    modifier whenDone(uint stepId) {
        require(stepDone[stepId]);
        _;
    }

    event NotEnoughGas(uint available, uint required);
    modifier executeNextIfEnoughGas() {
        _;
        if (msg.gas > minimumGas) {
            GasLeft(msg.gas);
            executeNext();
        } else {
            NotEnoughGas(msg.gas, minimumGas);
        }
    }

    event Refunded(address recipient, uint amount);
    event RefundFailed(address recipient, uint amount);
    function refund(address recipient, uint amount) internal {
        if (recipient.send(amount)) {
            Refunded(recipient, amount);
        } else {
            RefundFailed(recipient, amount);
        }
    }

    event NotEnoughPayed(uint sent, uint required);
    modifier costs(uint _amount) {
        if (msg.value < _amount) {
            NotEnoughPayed(msg.value, _amount);
            refund(msg.sender, msg.value);
            return;
        }
        _;
        if (msg.value > _amount) {
            refund(msg.sender, msg.value - _amount);
        }
    }

    // delete the used transition function, pretty hacky
    function removeTransition(uint index) {
        var i = index;
        while (i < transitionIds.length - 1) {
            transitionIds[i] = transitionIds[i+1];
            i++;
        }
        transitionIds.length--;
    }
    
    event TransitionE(uint previousId, address nextSender);
    function executeNext() {
        GasLeft(msg.gas);
        for (var index = 0; index < transitionIds.length; index++) {
            var tran = transitions[transitionIds[index]];
            TransitionE(tran.previousId, tran.nextSender);
            if (msg.sender == tran.nextSender && stepDone[tran.previousId]) {
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

    // --- Step 1 ---
    event DoSendContract(address participant);
    function sendContractStep() internal
        whenDone(transitions[1].previousId)
        executeNextIfEnoughGas()
    {
        DoSendContract(participants[0]);
        transitionIds.push(2);
    }

    event ContractSent(address sender, string text);
    string private contractSent;
    function sendContract(string _contract) external
        only(participants[0])
        whenDone(transitions[1].previousId)
        executeNextIfEnoughGas()
    {
        ContractSent(msg.sender, _contract);
        contractSent = _contract;
        stepDone[1] = true;
    }

    // --- Step 2 ---
    event DoSignContract(address participant);
    function signContractStep() internal
        whenDone(transitions[2].previousId)
        executeNextIfEnoughGas()
    {
        DoSignContract(participants[1]);
        transitionIds.push(3);
    }

    event ContractSigned(address sender, string text);
    string private signedContract;
    function signContract(string _signedContract) external
        whenDone(transitions[2].previousId)
        only(participants[1])
        executeNextIfEnoughGas()
    {
        ContractSigned(msg.sender, _signedContract);
        signedContract = _signedContract;
        stepDone[2] = true;
    }

    // --- Step 3 ---
    uint constant paymentAmount = 5 ether;
    event SendPayment(uint amount, address participant);
    function paymentStep() internal
        whenDone(transitions[3].previousId)
        executeNextIfEnoughGas()
    {
        SendPayment(paymentAmount, participants[0]);
        transitionIds.push(4);
    }

    event PaymentReceived(uint amount);
    function sendPayment() external
        whenDone(transitions[3].previousId)
        only(participants[0])
        payable
        costs(paymentAmount)
        executeNextIfEnoughGas()
    {
        stepDone[3] = true;
        participants[1].transfer(paymentAmount);
        PaymentReceived(paymentAmount);

    }

    // --- Step 4 ---
    function receivePaymentStep() internal
        whenDone(transitions[4].previousId)
        executeNextIfEnoughGas()
    {
        transitionIds.push(5);
        stepDone[4] = true;
    }

    // --- Step 5 ---
    event BearingsSent();
    function sendBearingsStep() internal
        whenDone(transitions[5].previousId)
        executeNextIfEnoughGas()
    {
        BearingsSent();
        transitionIds.push(6);
        stepDone[5] = true;
    }

    // --- Step 6 ---
    event DoSetFine();
    function analyseBearingsStep() internal
        whenDone(transitions[6].previousId)
        executeNextIfEnoughGas()
    {
        DoSetFine();
        transitionIds.push(7);
    }

    event Fine(uint percentage);
    uint private fine;
    function setFine(uint _fine) external
        whenDone(transitions[6].previousId)
        only(participants[0])
        executeNextIfEnoughGas()
    {
        fine = _fine;
        Fine(fine);
        stepDone[6] = true;
    }

    // --- Step 7 ---
    function fineDecision1() internal
        whenDone(transitions[7].previousId)
        executeNextIfEnoughGas()
    {
        if (fine == 0) {
            transitionIds.push(8);
        }
        else {
            transitionIds.push(9);
        }
        stepDone[7] = true;
    }

    // --- Step 8 ---
    event ConfirmationSent();
    function confirmationStep() internal
        whenDone(transitions[8].previousId)
        executeNextIfEnoughGas()
    {
        ConfirmationSent();
        transitionIds.push(12);
        stepDone[8] = true;
    }

    // --- Step 9 ---
    event FineRequestSent(uint percentage);
    function requestFineStep() internal
        whenDone(transitions[9].previousId)
        executeNextIfEnoughGas()
    {
        FineRequestSent(fine);
        transitionIds.push(10);
        stepDone[9] = true;
    }

    // --- Step 10 ---
    function fineDecision2() internal
        whenDone(transitions[10].previousId)
        executeNextIfEnoughGas()
    {
        if (fine < 100) {
            transitionIds.push(8);
        }
        else {
            transitionIds.push(11);
        }
        stepDone[10] = true;
    }

    // --- Step 11 ---
    event CancellationSent();
    function cancelContractStep() internal
        whenDone(transitions[11].previousId)
        executeNextIfEnoughGas()
    {
        CancellationSent();
        transitionIds.push(13);
        stepDone[11] = true;
    }

    // --- Step 12 ---
    event ProcessFinished();
    function processConfirmedFinishedStep() internal
        whenDone(transitions[12].previousId)
        executeNextIfEnoughGas()
    {
        ProcessFinished();
        stepDone[12] = true;
        selfdestruct(participants[0]);
    }

    // --- Step 13 ---
    function processCanceledFinishedStep() internal
        whenDone(transitions[13].previousId)
        executeNextIfEnoughGas()
    {
        ProcessFinished();
        stepDone[13] = true;
        selfdestruct(participants[0]);
    }
}
