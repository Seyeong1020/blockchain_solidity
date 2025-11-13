// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract Bank{
    address public owner; 
    mapping(address=>uint) public money; // 계정별 잔고를 설정하기 위해 mapping 사용 주소-금액 

    constructor(){
        owner = msg.sender;
        //컨트랙트 생성자를 owner로 설정
    }

    event Deposit(address _address, uint money); // 입금 계좌 주소와 입금 금액을 확인하기 위해 event 사용
    event Withdrawl(address _address, uint money); // 출금 계좌 주소와 출금 금액을 확인하기 위해 event 사용

    //트랜잭션 발신자가 owner가 아니면 에러가 나도록 하는 modifier 
    modifier onlyOwner(){
        require(owner == msg.sender, "Error: caller is not the owner");
        _;
    }

    //본인 계좌에 입금하는 함수 
    function deposit() public payable {
        emit Deposit(msg.sender, msg.value); //Deposit 메세지 출력 
        money[msg.sender] += msg.value; //mapping 데이터 중 money[msg.sender]에 msg.value만큼 더하기(입금)
    }

    //본인 계좌 amount만큼 출금하는 함수 
    function withdraw(uint256 amount) public{
        require(money[msg.sender]>=amount, "Error"); // 잔고보다 출금하려는 금액이 많으면 에러 발생
        emit Withdrawl(msg.sender, amount); //Withdrawl 메세지 출력
        money[msg.sender] -= amount; //mapping 데이터 중 money[msg.sender]에 amount만큼 빼기(출금)
        payable(msg.sender).transfer(amount); //msg.sender(트랜잭션 발신자)에게 amount만큼 이더를 보내줌 
    }

    //본인 계좌 잔고를 확인하는 함수
    //return : money[msg.sender]의 값 
    function getBalance() public view returns (uint256){
        return money[msg.sender];
    }

    //컨트랙트의 잔고를 확인하는 함수
    //onlyOwner()를 사용하여 컨트랙트 생성자만 사용할 수 있도록 설정 
    //return : 컨트랙트의 잔고(balance)
    function getContractBalance() public view onlyOwner() returns (uint256){
        return address(this).balance;
    }
}