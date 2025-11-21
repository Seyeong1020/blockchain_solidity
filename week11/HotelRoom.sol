// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract HotelRoom{
    enum Status{
        Vacant,
        Occupied
    }
    Status public currentStatus = Status.Vacant;

    event Occupy(address _address, uint _amount);
    address owner;
    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner(){
        require(msg.sender == owner, "only owner can use");
        _;
    }

    modifier onlyWhileVacant(){
        require(currentStatus == Status.Vacant, "room is not vacant");
        _;
    }

    modifier costs(uint _amount){
        require(msg.value >= _amount, "not enough money");
        _;
    }

    function book() public payable onlyWhileVacant costs(10 ether){
        currentStatus = Status.Occupied;
        emit Occupy(msg.sender, msg.value);
        payable(owner).transfer(msg.value);
    }

    function reset() public onlyOwner{
        currentStatus = Status.Vacant;
    }
}