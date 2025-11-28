// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract modifierOder{
    uint public a;
    uint public b;

    modifier plusA(){
        a = a+1;
        _;
    }
    modifier plusB(){
        _;
        b = b+1;
    }

    function mulA() public plusA(){
        a = a*2;
    }
    function mulB() public plusB(){
        b = b*2;
    }
}