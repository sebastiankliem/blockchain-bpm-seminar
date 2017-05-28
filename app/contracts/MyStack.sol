pragma solidity ^0.4.0;

contract MyStack {
    uint[] public stack;

    event StackUpdate(uint[] newStack);

    function push(uint number) {
        stack.push(number);
        StackUpdate(stack);
    }

    function pop() {
        delete stack[stack.length - 1];
        stack.length = stack.length - 1;
        StackUpdate(stack);
    }

    function getAll() constant returns (uint[]) {
        return stack;
    }
}