// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract Registry{

    //컨트랙트 정보를 나타낼 구조체 
    struct ContractInfo{
        address contractOwner; //컨트랙트를 등록한 사람 (컨트랙트 소유자)
        address contractAddress; //실제 배포된 컨트랙트 주소
        string description; //컨트랙트에 대한 설명
    }

    uint public numContracts; //등록된 컨트랙트 수

    event ContractRegistered(string _name, address _contractAddress, string _description);  // 컨트랙트 등록 이벤트
    event ContractDeleted(string _name); //컨트랙트 삭제 이벤트
    event ContractUpdated(string _name, string _type); // 컨트렉트 업데이트 이벤트 (어떤 업데이트인지 _type으로 확인 가능)

    //등록한 컨트랙트들을 저장할 매핑(이름=>컨트랙트 정보 구조체)
    mapping(string=>ContractInfo) public registeredContracts; 

    //지정된 이름의 컨트랙트에 대해 소유자만 접근하도록 제한하는 modifier
    modifier onlyOwner(string memory _name){
        //트랜잭션 발신자가 _name이 키인 컨트랙트의 소유자가 아니라면 접근 제한
        require(msg.sender == registeredContracts[_name].contractOwner, "Error: caller is not the contract's owner");
        _;
    }
    
    //Registry 컨트랙트가 생성될 때, 등록된 컨트랙트의 수 0으로 초기화
    constructor(){
        numContracts = 0;
    }

    //컨트랙트 등록 (이미 등록된 것이 아니라면(즉, address(0)이면 등록 가능하도록) 
    function registerContract(string memory _name,
                            address _contractAddress,
                            string memory _description) public {
        //_name에 해당하는 컨트랙트의 주소가 address(0)이 아니면 이미 등록된 것                        
        require(registeredContracts[_name].contractAddress==address(0), "The contract is already registered!");
        registeredContracts[_name] = ContractInfo(msg.sender, _contractAddress, _description); // 매핑에 컨트랙트 추가
        numContracts++; // 등록된 컨트랙트의 수 증가
        emit ContractRegistered(_name, _contractAddress, _description); /// 컨트랙트 등록 이벤트 발생 
    }

    //컨트랙트 삭제 (컨트랙트 소유자만 삭제 가능)
    function unregisterContract(string memory _name) public onlyOwner(_name){
        delete registeredContracts[_name]; //컨트랙트를 매핑에서 삭제
        emit ContractDeleted(_name); // 컨트랙트 삭제 이벤트 발생
    }

    //컨트랙트 소유자 변경 
    function changeOwner(string memory _name, address _newOwner) public onlyOwner(_name){
        require(_newOwner != address(0), "Error: newOwner is address(0)!"); // 새 소유자의 주소가 0이면 잘못된 것이므로 거부하도록 처리
        registeredContracts[_name].contractOwner = _newOwner; // 컨트랙트의 소유자 변경
        emit ContractUpdated(_name, "change ContractOwner"); // 컨트랙트 업데이트 이벤트 발생 (소유자 변경)
    }

    //컨트랙트 소유자 확인
    function getOwner(string memory _name) public view returns (address){
        return registeredContracts[_name].contractOwner; // 컨트랙트의 소유자 반환
        
    }

    //컨트랙트 주소 변경 (컨트랙트 소유자만 가능)
    function setAddr(string memory _name, address _addr) public onlyOwner(_name){
        registeredContracts[_name].contractAddress = _addr; //컨트랙트 주소 변경
        emit ContractUpdated(_name, "change ContractAddress"); // 컨트랙트 업데이트 이벤트 발생 (주소 변경)
    }

    //컨트랙트 주소 확인
    function getAddr(string memory _name) public view returns (address){
        return registeredContracts[_name].contractAddress; // 컨트랙트의 주소 반환
    }

    //컨트랙트 설명 변경 (컨트랙트 소유자만 가능)
    function setDescription(string memory _name, string memory _description) public onlyOwner(_name){
        registeredContracts[_name].description = _description; // 컨트랙트 설명 변경
        emit ContractUpdated(_name, "change description"); // 컨트랙트 업데이트 이벤트 발생 (설명 변경)
    }    

    //컨트랙트 설명 확인
    function getDescription(string memory _name) public view returns(string memory) {
        return registeredContracts[_name].description; // 컨트랙트의 설명 반환
    }  
}