// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract modifierTest{
    modifier numMoreThan1(uint _num){
        require(_num>1, "_num must be more than 1");
        _;
    }

    function getValue1(uint _num) public pure numMoreThan1(_num) returns(uint){
        return _num;
    }
    function getValue2(uint _num) public pure numMoreThan1(_num) returns(uint){
        return _num*2;
    }
}

