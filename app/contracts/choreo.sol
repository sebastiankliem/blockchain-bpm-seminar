pragma solidity ^0.4.11;

contract Choreo {
    uint constant minimumGas = 100000;
    address private participant1;
    address private participant2;

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
    event DoStep0();
    event DoStep2();
    event Done();
    event NotEnoughGas(uint gasLeft, uint gasExpected);
    event GasLeft(uint gasLeft);

    uint public lastStep;

	function Choreo(address _participant1, address _participant2) {
        participant1 = _participant1;
        participant2 = _participant2;
        
        createTransitions();

        stepDone[42] = true;
        transitionIds.push(0);
        lastStep = 42;
    }

    function createTransitions() {
        transitions[0] = Transition(42, participant1, step0);
        transitions[1] = Transition(0, participant1, step1);
        transitions[2] = Transition(1, participant1, gate0);
        transitions[3] = Transition(1, participant1, step2);
        transitions[4] = Transition(1, participant2, stepNonExistent);
        transitions[5] = Transition(2, participant1, step3);
        transitions[6] = Transition(3, participant1, gate1);
        transitions[7] = Transition(3, participant2, step5);
        transitions[8] = Transition(3, participant2, step6);
        transitions[9] = Transition(4, participant1, stepNonExistent);
        transitions[10] = Transition(5, participant1, gate2);
        transitions[11] = Transition(6, participant2, gate2);
        transitions[12] = Transition(5, participant1, step7);
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
    }

    event NextSender(address sender);
    function getNextSenders() {
        for (var i = 0; i < transitionIds.length; i++) {
            var tran = transitions[transitionIds[i]];
            NextSender(tran.nextSender);
        }
    }

    event LastStep(uint step);
    function getLastStep() {
        LastStep(lastStep);
    }

    event Length(uint length);
    function getLength() {
        Length(transitionIds.length);
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

    function step0()
        executeNextIfEnoughGas()
    {
        DoStep0();
        transitionIds.push(1);
    }

    uint step0Data;
    function step0Done(uint someData)
        only(participant1)
        whenDone(transitions[0].previousId)
    {
        step0Data = someData;
        stepDone[0] = true;
        lastStep = 0;
    }

    event Step0Data(uint data);
    function getStep0Data() {
        Step0Data(step0Data);
    }

    function step1() internal
        executeNextIfEnoughGas()
    {
        stepDone[1] = true;
        lastStep = 1;
        transitionIds.push(2);
    }

    function gate0() internal
        executeNextIfEnoughGas()
    {
        if (true) {
            transitionIds.push(3);
        } else {
            transitionIds.push(4);
        }
    }

    function stepNonExistent() internal {}

    function step2() internal
        executeNextIfEnoughGas()
    {
        DoStep2();
        transitionIds.push(5);
    }

    function step2Done() {
        if (stepDone[transitions[2].previousId]) {
            stepDone[2] = true;
            lastStep = 2;
        }
    }

    function step3() internal
        executeNextIfEnoughGas()
    {
        stepDone[3] = true;
        lastStep = 3;
        transitionIds.push(6);
    }

    function gate1() internal
        executeNextIfEnoughGas()
    {
        transitionIds.push(7);
        transitionIds.push(8);
    }

    //function step4() internal {
    //    stepDone[4] = true;
    //    transitionIds.push(9);
    //}

    function step5() internal
        executeNextIfEnoughGas()
    {
        stepDone[5] = true;
        lastStep = 5;
        transitionIds.push(10);
    }

    function step6() internal
        executeNextIfEnoughGas()
    {
        stepDone[6] = true;
        lastStep = 6;
        transitionIds.push(11);
    }

    function gate2() {
        uint[2] memory steps = [uint(5), 6];
        if (andJoinGateway(steps)) {
            transitionIds.push(12);
            if (msg.gas > minimumGas) {
                GasLeft(msg.gas);
                executeNext(msg.sender);
            } else {
                NotEnoughGas(msg.gas, minimumGas);
            }
        }
    }

    function step7() internal {
        stepDone[7] = true;
        Done();
    }

    function andJoinGateway(uint[2] steps) internal returns (bool) {
        var stepThrough = true;
        for (var index = 0; index < steps.length; index++) {
            stepThrough = stepThrough && stepDone[steps[index]];
        }
        return stepThrough;
    }

    function andJoinGateway(uint[3] steps) internal returns (bool) {
        var stepThrough = true;
        for (var index = 0; index < steps.length; index++) {
            stepThrough = stepThrough && stepDone[steps[index]];
        }
        return stepThrough;
    }

    function andJoinGateway(uint[4] steps) internal returns (bool) {
        var stepThrough = true;
        for (var index = 0; index < steps.length; index++) {
            stepThrough = stepThrough && stepDone[steps[index]];
        }
        return stepThrough;
    }
}
