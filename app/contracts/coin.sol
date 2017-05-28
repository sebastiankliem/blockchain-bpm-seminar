pragma solidity ^0.4.7;

contract Coin {
    // The keyword "public" makes those variables
    // readable from outside.
    address public minter;
    mapping (address => uint) public balances;
    uint public wentWrong;

    // Events allow light clients to react on
    // changes efficiently.
    event Sent(address from, address to, uint amount);

    // This is the constructor whose code is
    // run only when the contract is created.
    function Coin() {
        minter = msg.sender;
        wentWrong = 0;
    }

    function mint(address receiver, uint amount) {
        if (msg.sender != minter) {
            wentWrong += 1;
            return;
        }
        balances[receiver] += amount;
    }

    function send(address receiver, uint amount) {
        if (balances[msg.sender] < amount) {
            wentWrong += 1;
            return;
        }
        balances[msg.sender] -= amount;
        balances[receiver] += amount;
        Sent(msg.sender, receiver, amount);
    }
}