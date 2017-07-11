pragma solidity ^0.4.7;
contract SimpleStorage {
  uint public storedData;

  uint64[] blubs;

  function SimpleStorage(uint initialValue) {
    storedData = initialValue;
    blubs = [uint64(1)];
  }

  function set(uint x) {
    storedData = x;
  }

  function get() constant returns (uint retVal) {
    return storedData;
  }

  function expensiveGet(uint64 num) returns (uint retVal) {
    blubs.length = 0;
    for (uint64 i = 0; i < num; i++) {
      blubs.push(i);
    }
    return get();
  }

  function expensiveGet2(uint64 num) returns (uint retVal) {
    blubs.length = 0;
    for (uint64 i = 0; i < num; i++) {
      blubs.push(i);
    }
    return storedData;
  }

}
