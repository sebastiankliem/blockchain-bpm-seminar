pragma solidity ^0.4.8;

contract Choreo {
    address public sender;
    address public receiver;
    mapping (bytes32 => string) public messages;
    mapping (bytes32 => bool) public messageSeen;
    mapping (bytes32 => string) public answer;

    event NewMessage(bytes32 messageHash, string message);
    event MessageAnswered(bytes32 messageHash, string answer);

    function Choreo(address _sender, address _receiver) {
        sender = _sender;
        receiver = _receiver;
    }

    function send(string message) {
        bytes32 hash = sha3(sender, receiver, message, now);
        messageSeen[hash] = false; // same as default value
        messages[hash] = message;
        NewMessage(hash, message);
    }

    function sendAnswer(bytes32 messageHash, string message) {
        messageSeen[messageHash] = true;
        answer[messageHash] = message;
        MessageAnswered(messageHash, message);
    }
}