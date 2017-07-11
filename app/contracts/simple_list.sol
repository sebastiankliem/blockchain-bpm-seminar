pragma solidity ^0.4.8;
contract SimpleList {
  uint64[] list;

  function SimpleList() {
    list.push(1);
    list.push(2);
    list.push(3);
    list.push(4);
  }

  event Length(uint length);
  function getLength() {
    Length(list.length);
  }

}
