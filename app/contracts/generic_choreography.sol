pragma solidity ^0.4.8;

contract GenericChoreography {

	//Attributes need to be generated
	string public name = "Choreography name";
    address private participant1;
    address private participant2;
    boolean private isBranched;

    //Mapping for branching purposes
    mapping(uint => address) nextSenders;
    mapping(uint => function () internal) transitions;
    mapping(uint => boolean) preconditions;

    //Generate decision logic attributes here!

    event ContractSent(address participant1, address participant2);
    event activityEvent();

	//Generated constructor - depending on number of participants
	function GeneralChoreography(address _participant1, address _participant2) {
        name = _name;
        participant1 = _participant1;
        participant2 = _participant2;
        isBranched = False;

        transitions[0] = step0();
    }

    function executeNext() {
        if (check_for_same_transitions()) {
            transitions[0]();
        } else {
        	//TODO: msg.sender == is sender for one branch -> execute that branch only
        	//user isBranched attribute
        	//TODO: if branches have same sender, ask for input?
        }
    }

    function check_for_same_transitions() {
    	if (transitions.length <= 1) {
    		return False;
    	} else {
    		for(uint i = 1; i < transitions.length; i++) {
    			if(transitions[i-1] != transitions[i]) {
    				return False;
    			}
    		}
    		return True;
    	}
    }

    function step0() internal {
        //sendTransaction("Contract send!")
        ContractSent(participant1, participant2);
        transitions[0] = activity;
        nextSenders[0] = participant2;
    }

    function activity() internal {
        id = <uint>;
        if(preconditions[id]) {
        	activityEvent();
        	transitions[0] = activityOrGateway;
        	nextSenders[0] = participant;
        }
    }

    function xorSplitGateway() internal {
    	//decision logic attribute needed
    	//decision logic -> set transitions[0] and nextSenders[0]
    	executeNext();
    }

    function andSplitGateway() internal {
    	transitions[0] = activityOrGatewayX;
    	nextSenders[0] = participantX;
    	transitions[1] = activityOrGatewayY;
    	nextSenders[1] = participantY;
    	isBranched = True;
    	executeNext();
    }

    function xorJoinGateway() internal {
    	transitions[0] = activityOrGateway;
    	nextSenders[0] = participant;
    	executeNext();
    }

    function andJoinGateway() internal {
    	transitions[0] = activityOrGateway;
    	nextSenders[0] = participant;
    	isBranched = False;
    	executeNext();
    }
}