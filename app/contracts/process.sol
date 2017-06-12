pragma solidity ^0.4.8;

contract Process {

    enum ElementType { Task, ParSplit, XorSplit}

    uint index;
    ElementType[] elements;

    function Process() {
        index = 0;
        elements.push(ElementType.Task);
        elements.push(ElementType.ParSplit);
        elements.push(ElementType.Task);
    }

    function goNext() returns (ElementType) {
        var element = elements[index];
        index += 1;
        return element;
    }
}