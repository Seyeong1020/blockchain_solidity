// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract Ex6_16{
    event Obtain(address form, uint amount);

    receive() external payable { 
        emit Obtain(msg.sender, msg.value);
    }

    function getBalance() public view returns(uint){
        return address(this).balance;
     }

    function sendEther() public payable{
        payable(address(this)).transfer(msg.value);
    }
}