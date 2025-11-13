// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract Counter{
    uint private counter = 0;
    function get() public view returns(uint){
        return counter;
    }
    function inc() public {
        counter+=1;
    }
    function dec() public {
        counter -= 1;
        //if (counter <= 0) 확인 추가 
    }
}