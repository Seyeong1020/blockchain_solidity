// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract ERC20StdToken {
    mapping (address => uint256) balances; // 각 계정이 소유한 토큰 수 저장
    mapping(address => mapping(address => uint256)) allowed; // 각 계정이 다른 계정들이 대리 전송할 수 있도록 허용한 토큰 수 저장
    uint private total; // 총 발행 토큰 수
    string public name; // 토큰 이름
    string public symbol; // 토큰 심볼
    uint public decimals; // 토큰의 소수점 자리수 (얼만큼 쪼갤 수 있는지)

    // indexed가 뭘까?
    /*
    이렇게 indexed를 포함해서 이벤트를 방출하면 
    나중에 web3에서 getPastEvents등 함수들을 사용하여 filter해서 특정 값을 가지고 올 수 있다.
    */
    event Transfer(address indexed from, address indexed to, uint256 value); // 직접 전송할 때 이벤트
    event Approval(address indexed owner, address indexed spender, uint256 value); // 위임 전송할 때 이벤트

    constructor (string memory _name, string memory _symbol, uint _totalSupply){
        total = _totalSupply;
        name = _name;
        symbol = _symbol;
        decimals = 0;
        balances[msg.sender] = _totalSupply;
        emit Transfer(address(0x0), msg.sender, _totalSupply);
    }

    // 전체 발행량, 발행한 토큰 수를 반환하는 함수
    function totalSupply() public view returns (uint256){
        return total;
    }

    // 특정 계정의 잔액, _owner가 소유한 토큰 수를 반환하는 함수
    function balanceOf(address _owner) public view returns(uint256 balance){
        return balances[_owner];
    }

    // 남아 있는 허용된 잔액 반환하는 함수
    function allowance(address _owner, address _spender) public view returns (uint256 remaining){
        return allowed[_owner][_spender];
    }

    // 직접 전송
    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balances[msg.sender] >= _value, "not enough token"); // 잔액 검사
        if ( (balances[_to] + _value) >= balances[_to]) { // overflow 검사
            balances[msg.sender] -= _value; // 토큰 이전 (from 잔액 조정, _value만큼 -)
            balances[_to] += _value; // 토큰 이전 (to 잔액 조정, _value만큼 +)
            emit Transfer(msg.sender, _to, _value); //Tranfer 이벤트 발생
            return true; // 성공
        }
        else{ // overflow 발생시
            return false; // 실패
        }
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(balances[_from] >= _value, "not enough token");
        require(allowed[_from][msg.sender] >= _value, "not enough allowed token");

        if ( (balances[_to] + _value) >= balances[_to]) { // overflow 검사
            balances[_from] -= _value; // 토큰 이전 (from 잔액 조정, _value만큼 -)
            balances[_to] += _value; // 토큰 이전 (to 잔액 조정, _value만큼 +)
            allowed[_from][msg.sender] -= _value;
            emit Transfer(msg.sender, _to, _value); //Tranfer 이벤트 발생
            return true; // 성공
        }
        else{ // overflow 발생시
            return false; // 실패
        }
    }

    // 특정 주소에 토큰 사용 권한 부여
    function approve(address _spender, uint256 _value) public returns (bool success){
        allowed[msg.sender][_spender] = _value; //_value만큼 _spender에게 권한 부여
        emit Approval( msg.sender, _spender, _value); // Approval 이벤트 발생
        return true;
    }
}