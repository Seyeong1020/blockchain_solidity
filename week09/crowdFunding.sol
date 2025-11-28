// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract crowdFunding{
    struct Investor{ // 투자자 구조체 
        address addr; //투자자 주소
        uint amount; //투자액(wei 단위)
    }

    mapping (uint=>Investor) public investors; //투자자 번호와 Investor 구조체 매핑 

    address public owner; //컨트랙트 생성자 저장을 위한 address 변수
    uint public numInvestors; //투자자 수
    uint public deadline; // 투자 마감일(마감시간)
    string public status; //모금 활동 상태를 저장하고 있는 string
    bool public ended; //모금종료 여부
    uint public goalAmount; //목표액 (ETH 단위)
    uint public totalAmount; //총 모금액
    address [] investInfo; //투자자 목록(주소)을 저장하는 배열 

    event Funded(address _address, uint amount); // 투자 발생 시 이벤트

    modifier onlyOwner(){ //소유자만 실행 가능하도록 하는 modifier
        require(msg.sender==owner, "Error: caller is not the owner"); //트랜잭션 발생자가 owner가 아니면 Error로 취급
        _;
    }

    constructor(uint _duration, uint _goalAmount){ // 생성자(마감기간(초), 목표액(ETH))
        owner = msg.sender; 

        deadline = block.timestamp + _duration; //마감일 설정
        goalAmount = 1 ether * _goalAmount; //웨이 단위로 변홤
        status = "Funding"; // 상태초기화
        ended = false; //모금 종료 여부 false로 초기화

        numInvestors = 0; // 투자자 수 초기화
        totalAmount = 0; // 총 모금액 초기화 
    }

    // 투자자가 투자할 때 호출하는 함수
    function fund() public payable{ 
        // payable => 자동으로 컨트랙트에 돈이 보내지는 것임
        require(ended==false, "already finish"); // 투자가 종료되었으면 함수 호출 거부
        investors[numInvestors] = Investor(msg.sender, msg.value); //mapping에 투자자 정보 추가 (정보 등록)
        investInfo.push(msg.sender); // 투자자 주소를 배열에 추가 (투자자 목록 조회 함수를 위해서)
        totalAmount += msg.value; //총 투자금에 투자금 추가
        numInvestors += 1; //투자자 수 증가
        emit Funded(msg.sender, msg.value); // 이벤트 기록하지 
    }

    // 마감 후 목표 달성 여부 확인, 상태 처리 함수 (소유자만 가능하도록)
    function checkGoalReached() public onlyOwner{
        if((block.timestamp < deadline)||ended == true){
            revert("not finish"); //마감일이 지나지 않았다면 revert()
        }
        ended = true; // 모금 종료 여부 true로 설정 
        if(totalAmount >= goalAmount){ //만약 투자금이 목표액 이상이라면
            status = "Campaign Succeeded"; //캠페인 성공
            payable(owner).transfer(totalAmount); //소유자에게 투자금 송금
        }
        else{ //투자금이 목표액 미만인 경우
            status = "Campaign Failed"; //캠페인 실패
            for (uint i = 0; i<numInvestors; i++){  //numInvestors 이용하여 반복문 돌리기 -> 송금, 반복문 사용은 지양-> 
                payable(investors[i].addr).transfer(investors[i].amount);
            }
        }
    }

    // 투자자 목록 조회 함수
    function getInvestors() public view returns(address [] memory){ 
        return investInfo; //investInfo 배열 반환
    }
}

