// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract enumTest{
    event information(string info);
    enum FoodProcess{
        order,
        takeAway,
        delivery,
        payment
    }
    FoodProcess public foodStatus;

    constructor(){
        foodStatus = FoodProcess.payment;
    }

    modifier test(FoodProcess _foodStatus){
        require(foodStatus == _foodStatus, "error");
        _;
        emit information("success");
        
    }

    function orderFood() public test(FoodProcess(3)){
        foodStatus = FoodProcess.order;
    }

    function takeAwayFood() public test(FoodProcess.order){
        foodStatus = FoodProcess.takeAway;
    }

    function deliveryFood() public test(FoodProcess.takeAway) {
        foodStatus = FoodProcess.delivery;
    }

    function paymentFood() public test(FoodProcess.delivery){
        foodStatus = FoodProcess.payment;
    }
}