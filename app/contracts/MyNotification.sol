pragma solidity ^0.4.0;

contract MyStack {
    uint[] public stack;

    function push(uint number) {
        stack.push(number);
    }

    function pop() {
        delete stack[stack.length - 1];
        stack.length = stack.length - 1;
    }

    function getAll() constant returns (uint[]) {
        return stack;
    }
}