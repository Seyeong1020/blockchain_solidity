// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract Lottery {
    address public manager; //배포자를 담을 address 변수 manager
    address[] public players; //참가자 address를 담은 배열
    enum Status{ //배팅이 가능한지 단계를 나타내는 enum
        Possible, // 배팅 가능
        Impossible // 배팅 불가능
    }
    Status current = Status.Impossible; // 현재 상태를 배팅 불가능한 상태로 기본 설정

    // 현재 상태가 _status인지 확인하는 modifier
    modifier checkStatus(Status _status){ 
        require(current == _status, "status err"); //현재 상태가 _status가 아니면 거부하도록
        _;
    }

    event PlayerInfo(address _address); // 이벤트 : 참가자 정보(참가자 address) (베팅 참여시 발생하도록)
    event WinnerInfo(address _address, uint _amount); // 이벤트 : 우승자 정보(우승자 address)와 금액 (우승자가 골라졌을 때 발생하도록)
    
    // 트랜잭션 발신자가 배포자인지 확인하는 modifier
    modifier restricted(){
        require(msg.sender == manager, "only manager can to"); //트랜잭션 발신자가 manager가 아니면 거부하도록
        _;
    }

    // 생성자 : 컨트랙트 배포 당시의 발신자를 manager로 설정
    constructor(){
        manager = msg.sender; 
    }

    // 참가자 정보를 반환하는 함수 
    // players 배열 반환
    function getPlayers() public view returns(address[] memory){
        return players; // players 배열 반환
    }

    // 배팅 참여하는 함수
    // checkStatus modifier를 이용하여 현재 상태가 Possible인지 확인
    // payable이기 때문에 참가자들이 배팅한 돈은 컨트랙트에 보내짐
    function enter() payable public checkStatus(Status.Possible){
        require(msg.sender != manager, "manager can not participate"); // 트랜잭션 발신자가 manager라면 배팅에 참여하지 못하도록 거부
        require(msg.value == 1 ether, "value is not 1 ether"); // 배팅에는 1 ether만 가능, 1 ether(msg.value)가 아니라면 거부
        uint i;
        for (i=0; i<players.length;i++){
            require(msg.sender != players[i], "Duplicate participation is not allowed");
        } // 이미 players 배열에 있는 사람인지 확인, 있다면 거부 (중복 참여 불가하도록)
        players.push(msg.sender); // players 배열에 트랜잭션 발신자 추가 (배팅 참여)
        emit PlayerInfo(msg.sender); // PlayerInfo 이벤트 발생시키기 (참가자 정보)
    }

    // 랜덤 숫자를 만드는 함수
    // 랜덤숫자 반환
    function random() private view returns(uint){
        return uint(keccak256(abi.encodePacked(block.number, block.timestamp, players.length))); //랜덤 숫자 반환
    }

    // 우승자를 뽑는 함수
    // restricted modifier를 이용하여 manager만 해당 함수를 호출 가능하도록 함
    // checkStatus modifier을 이용하여 배팅 불가능한 상태여야 실행되도록 함 (배팅 가능한 상태인데 바로 우승자를 뽑지 않도록)
    function pickWinner() public restricted checkStatus(Status.Impossible){
        address winner = players[random()%players.length]; //랜덤 숫자를 players의 길이(참가자 수)로 나눠, 그 나머지 값(0 ~ 참가자 수-1)을 우승자의 인덱스로 사용
        payable(winner).transfer(address(this).balance); //우승자에게 컨트랙트에 있는 돈(참가자들이 배팅한 돈) 전체를 보냄
        emit WinnerInfo(winner, address(this).balance); // WinnerInfo 이벤트 발생시키기 (우승자 정보, 상금)
        delete players; // 다시 처음부터 진행할 수 있도록 players 배열 초기화
    }

    // 상태를 바꾸는 함수 (Possible <-> Impossible)
    // restricted modifier를 이용하여 manager만 해당 함수를 호출 가능하도록 함
    function changeStatus() public restricted{
        if(current==Status.Impossible){ // 현재 상태가 Impossible이면
            current = Status.Possible; // 상태를 Possible로 변경
        }
        else{ // 현재 상태가 Possible이면
            current = Status.Impossible; // 상태를 Impossible로 변경
        }
    }
}