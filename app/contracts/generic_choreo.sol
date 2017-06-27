pragma solidity ^0.4.8;

contract GenericChoreo {

	//Attributes need to be generated
	string public name = "Choreography name";
    address private participant1;
    address private participant2;

    //Mapping for branching purposes
    mapping(uint => address) nextSenders;
    mapping(uint => bool) stepDone;

    Transition[] transitions;

    struct Transition {
        uint id;
        address nextSender;
        function () internal func;
    }

    //Generate decision logic attributes here!
    event DoStep0();
    event DoStep2();
    event Done();

	//Generated constructor - depending on number of participants
	function GeneralChoreography(string _name, address _participant1, address _participant2) {
        name = _name;
        participant1 = _participant1;
        participant2 = _participant2;

        stepDone[42] = true;
        transitions.push(Transition(42, participant1, step0));
    }

    function executeNext() {
        for (var index = 0; index < transitions.length; index++) {
            var tran = transitions[index];
            if (msg.sender == tran.nextSender && stepDone[tran.id]) {
                tran.func();
                // delete the used transition function, very hacky :-/
                var i = index;
                while (i < transitions.length - 1) {
                    transitions[i] = transitions[i+1];
                    i++;
                }
                transitions.length--;
            }
        }
    }

    function step0() {
        DoStep0();
        transitions.push(Transition(0, participant1, step1));
    }

    function step0Done() {
        stepDone[0] = true;
        executeNext();
    }

    function step1() internal {
        stepDone[1] = true;
        transitions.push(Transition(1, msg.sender, gate0));
        executeNext();
    }

    function gate0() internal {
        if (true) {
            transitions.push(Transition(1, msg.sender, step2));
            executeNext();
        } else {
            transitions.push(Transition(1, msg.sender, stepNonExistent));
            executeNext();
        }
    }

    function stepNonExistent() internal {}

    function step2() internal {
        DoStep2();
        transitions.push(Transition(2, participant1, step3));
    }

    function step2Done() {
        stepDone[2] = true;
        executeNext();
    }

    function step3() internal {
        stepDone[3] = true;
        transitions.push(Transition(3, msg.sender, gate1));
        executeNext();
    }

    function gate1() internal {
        transitions.push(Transition(3, msg.sender, step5));
        transitions.push(Transition(3, msg.sender, step6));
        executeNext();
    }

    //function step4() internal {
    //    stepDone[4] = true;
    //    transitions.push(Transition(4, msg.sender, gate2));
    //}

    function step5() internal {
        stepDone[5] = true;
        transitions.push(Transition(5, msg.sender, gate2));
        executeNext();
    }

    function step6() internal {
        stepDone[6] = true;
        transitions.push(Transition(6, msg.sender, gate2));
        executeNext();
    }

    function gate2() internal {
        // we cannot use array literals because they have fixed size and there is no conversion to variable size
        uint[] memory steps;
        steps[0] = 5;
        steps[1] = 6;
        if (andJoinGateway(steps)) {
            transitions.push(Transition(5, msg.sender, step7));
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