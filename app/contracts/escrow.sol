pragma solidity ^0.4.11;

contract Escrow {
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

    //Generate decision logic attributes here!
    event Done();
    event NotEnoughGas(uint gasLeft, uint gasExpected);
    event GasLeft(uint gasLeft);

	function Escrow(address _participant0, address _participant1) {
        participants[0] = _participant0;
        participants[1] = _participant1;
        
        createTransitions();

        stepDone[0] = true;
        transitionIds.push(1);
    }

    function createTransitions() {
        transitions[1] = Transition(0, participants[0], step1);
        transitions[2] = Transition(1, participants[0], paymentStep);
        transitions[3] = Transition(2, participants[0], noop); // is user triggered
        transitions[4] = Transition(3, participants[0], stepAfter);
    }

    modifier only(address _participant) {
        require(msg.sender == _participant);
        _;
    }

    modifier whenDone(uint _stepId) {
        require(stepDone[_stepId]);
        _;
    }

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

    function noop() internal { }

    // <Debug>
    event NextSender(address sender);
    function getNextSenders() {
        for (var i = 0; i < transitionIds.length; i++) {
            var tran = transitions[transitionIds[i]];
            NextSender(tran.nextSender);
        }
    }

    event Length(uint length);
    function getLength() {
        Length(transitionIds.length);
    }
    // </Debug>

    // delete the used transition function, pretty hacky
    function removeTransition(uint index) {
        var i = index;
        while (i < transitionIds.length - 1) {
            transitionIds[i] = transitionIds[i+1];
            i++;
        }
        transitionIds.length--;
    }

    event ExecuteNext();
    event TransitionE(uint previousId, address nextSender);
    function executeNext() {
        ExecuteNext();
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

    function step1() internal
        whenDone(transitions[1].previousId)
        executeNextIfEnoughGas()
    {
        stepDone[1] = true;
        transitionIds.push(2);
    }

    uint constant paymentAmount = 5 ether;
    event SendPayment(uint amount, address participant);
    function paymentStep() internal
        whenDone(transitions[2].previousId)
    {
        SendPayment(paymentAmount, participants[0]);
        stepDone[2] = true;
        transitionIds.push(4);
    }

    function sendPayment()
        whenDone(transitions[3].previousId)
        only(participants[0])
        payable
        costs(paymentAmount)
        executeNextIfEnoughGas()
    {
        stepDone[3] = true;
        participants[1].transfer(paymentAmount);
    }

    function stepAfter() internal
        whenDone(transitions[4].previousId)
        executeNextIfEnoughGas()
    {
        stepDone[4] = true;
        Done();
    }
}
