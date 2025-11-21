// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract Lottery {
    address public manager;
    address[] public players;
    enum Status{
        Possible,
        Impossible
    }
    Status current = Status.Impossible;

    modifier checkStatus(Status _status){
        require(current == _status, "status err");
        _;
    }

    event PlayerInfo(address _address);
    event WinnerInfo(address _address, uint _amount);
    modifier restricted(){
        require(msg.sender == manager, "only manager can to");
        _;
    }

    constructor(){
        manager = msg.sender;
    }

    function getPlayers() public view returns(address[] memory){
        return players;
    }

    function enter() payable public checkStatus(Status.Possible){
        require(msg.sender != manager, "manager can not participate");
        require(msg.value == 1 ether, "value is not 1 ether");
        uint i;
        for (i=0; i<players.length;i++){
            require(msg.sender != players[i], "Duplicate participation is not allowed");
        }
        players.push(msg.sender);
        emit PlayerInfo(msg.sender);
    }

    function random() private view returns(uint){
        return uint(keccak256(abi.encodePacked(block.number, block.timestamp, players.length)));
    }

    function pickWinner() public restricted{
        address winner = players[random()%players.length];
        payable(winner).transfer(address(this).balance);
        emit WinnerInfo(winner, address(this).balance);
        delete players;
    }

    function changeStatus() public restricted{
        if(current==Status.Impossible){
            current = Status.Possible;
        }
        else{
            current = Status.Impossible;
        }
    }
}