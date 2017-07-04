pragma solidity ^0.4.8;

contract GenericChoreography {

	//Attributes need to be generated
	string public name = "Choreography name";
    address private participant1;
    address private participant2;

    //Mapping for branching purposes
    mapping(uint => address) nextSenders;
    mapping(uint => bool) stepDone;

    uint[] transitionIds;
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

	//Generated constructor - depending on number of participants
	function GenericChoreography(address _participant1, address _participant2) {
        participant1 = _participant1;
        participant2 = _participant2;
        
        createTransitions();

        stepDone[42] = true;
        transitionIds.push(0);
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
        transitions[9] = Transition(4, participant1, gate2);
        transitions[10] = Transition(5, participant1, gate2);
        transitions[11] = Transition(6, participant2, gate2);
        transitions[12] = Transition(5, participant1, step7);
    }

    function executeNext() {
        for (var index = 0; index < transitionIds.length; index++) {
            var tran = transitions[transitionIds[index]];
            if (msg.sender == tran.nextSender && stepDone[tran.previousId]) {
                tran.func();
                // delete the used transition function, very hacky :-/
                var i = index;
                while (i < transitionIds.length - 1) {
                    transitionIds[i] = transitionIds[i+1];
                    i++;
                }
                transitionIds.length--;
            }
        }
    }

    function step0() internal {
        DoStep0();
        transitionIds.push(1);
    }

    function step0Done() {
        stepDone[0] = true;
        executeNext();
    }

    function step1() internal {
        stepDone[1] = true;
        transitionIds.push(2);
        executeNext();
    }

    function gate0() internal {
        if (true) {
            transitionIds.push(3);
            executeNext();
        } else {
            transitionIds.push(4);
            executeNext();
        }
    }

    function stepNonExistent() internal {}

    function step2() internal {
        DoStep2();
        transitionIds.push(5);
    }

    function step2Done() {
        stepDone[2] = true;
        executeNext();
    }

    function step3() internal {
        stepDone[3] = true;
        transitionIds.push(6);
        executeNext();
    }

    function gate1() internal {
        transitionIds.push(7);
        transitionIds.push(8);
        executeNext();
    }

    //function step4() internal {
    //    stepDone[4] = true;
    //    transitionIds.push(9);
    //}

    function step5() internal {
        stepDone[5] = true;
        transitionIds.push(10);
        executeNext();
    }

    function step6() internal {
        stepDone[6] = true;
        transitionIds.push(11);
        executeNext();
    }

    function gate2() internal {
        // we cannot use array literals because they have fixed size and there is no conversion to variable size
        uint[] memory steps;
        steps[0] = 5;
        steps[1] = 6;
        if (andJoinGateway(steps)) {
            transitionIds.push(12);
            executeNext();
        }
    }

    function step7() internal {
        stepDone[7] = true;
        Done();
    }

    function andJoinGateway(uint[] steps) internal returns (bool) {
        var stepThrough = true;
        for (var index = 0; index < steps.length; index++) {
            stepThrough = stepThrough && stepDone[steps[index]];
        }
        return stepThrough;
    }
}