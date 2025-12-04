// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

interface ERC165 { //스마트 컨트랙트가 어떤 인터페이스를 지원하는지 판별하는 표준
    function supportsInterface(bytes4 interfaceID) external view returns (bool);
}

interface ERC721 is ERC165 {
    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId); //from에서 to로 tokenID NFT의 소유권 변경
    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId); // NFT의 approved가 변경되거나 재확인 때 발생
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved); //operator 주소에 대해 owner의 모든 NFT 전송 권한을 위임하거나 철회할 때 발생

    function balanceOf(address _owner) external view returns (uint256); //_owner의 NFT 보유량
    function ownerOf(uint256 _tokenId) external view returns (address); // _tokenId NFT의 소유자 주소
    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes calldata data) external payable ; // 토큰을 안전하게 전송, from에서 to로 _tokenId 토큰 전송
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable; // 토큰을 안전하게 전송, from에서 to로 _tokenId 토큰 전송
    function transferFrom(address _from, address _to, uint256 _tokenId) external payable; // from에서 to로 _tokenId 토큰 전송
    function approve(address _approved, uint256 _tokenId) external payable; // _approved 주소에 대해 _tokenId 토큰 전송 권한 부여
    function setApprovalForAll(address _operator, bool _approved) external; // _operator 주소에 대해 모든 NFT 전송 권한을 위임하거나 철회
    function getApproved(uint256 _tokenId) external view returns (address); // _tokenId 토큰에 대한 전송 권한이 부여된 주소
    function isApprovedForAll(address _owner, address _operator) external view returns (bool); //

}

interface ERC721TokenReceiver {
    function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes calldata _data) external returns(bytes4);
}

contract ERC721StdNFT is ERC721 {
    address public founder; // NFT 발행자 주소

    mapping (uint => address) internal _ownerOf; //토큰 ID에 대한 소유자 주소(tokenId -> owner)
    mapping (address => uint) internal _balanceOf; // 특정 주소가 보유한 NFT 개수 (owner -> number of NFTs)
    mapping (uint => address) internal _approvals;  // 특정 NFT를 대신 전송할 권리를 부여받은 주소를 저장 (tokenId -> approved)
    mapping (address => mapping (address => bool)) internal _operatorApprovals; // 특정 주소가 소유자의 모든 NFT를 관리할 권한이 있는지

    string public name; // 토큰 이름
    string public symbol; // 토큰 심볼

    constructor (string memory _name, string memory _symbol){
        founder = msg.sender; // 컨트랙트 생성자를 NFT 발행자 주소로 설정
        name = _name; // 토큰 이름 설정
        symbol = _symbol; // 토큰 심볼 설정
        for (uint tokenID = 1; tokenID <=5; tokenID++){ //1번~5번 tokenID를 배포자에게 자동 발행
            _mint(msg.sender, tokenID);
        }
    }

    function _mint(address to, uint id) internal {
        require(to!=address(0), "mint to zero address"); // 줄 주소(to)가 0이면 실패
        require(_ownerOf[id] == address(0), "already minted"); // 토큰 ID 소유자 주소가 0이어야 함. 아니면 이미 발행된 것

        _balanceOf[to]++; // to가 가진 NFT 수 증가
        _ownerOf[id] = to; // id 토큰의 소유자를 to로 설정

        emit Transfer(address(0), to, id); // Transfer 이벤트 발생
    }

    function mintNFT(address to, uint256 tokenID) public {
        require(msg.sender==founder, "not an authorized minter");
        _mint(to, tokenID);
    }

    // _tokenId NFT의 소유자 주소 반환하는 함수
    function ownerOf(uint256 _tokenId) external view returns (address){
        address owner = _ownerOf[_tokenId]; // _tokenId의 소유자
        require(owner != address(0), "token doesn't exist"); // 소유자 주소가 0이라면 토큰이 존재하지 않는 것
        return owner;
    }

    //_owner의 NFT 보유량을 반환하는 함수
    function balanceOf(address _owner) external view returns (uint256){
        require(_owner!=address(0), "balance query for the zero address"); //주소가 0이면 없는 주소에 대해 보유량을 확인하는 것이기 때문에 실패 시키기
        return _balanceOf[_owner]; // _balanceOf를 이용하여 보유량 반환
    }

    // _tokenId 토큰에 대한 전송 권한이 부여된 주소 반환하는 함수
    function getApproved(uint256 _tokenId) external view returns (address) {
        require(_ownerOf[_tokenId] != address(0), "approved query for nonexistent token"); // 토큰이 존재하지 않으면 실패
        return _approvals[_tokenId];  // _tokenId 토큰에 대한 전송 권한이 부여된 주소 반환
    }

    // _owner가 _operator에게 자신의 모든 NFT 토큰에 대한 전송 권한을 부여했는지 확인하는 함수
    function isApprovedForAll(address _owner, address _operator) external view returns (bool){
        return _operatorApprovals[ _owner][_operator]; // 권한 부여했는지 여부 반환
    }

    // 주어진 토큰 ID의 전송을 다른 주소에게 허가하는 함수
    function approve(address _approved, uint256 _tokenId) external payable {
        address owner = _ownerOf[_tokenId]; // _ownerOf를 이용하여 토큰 소유자 얻기
        require( // 토큰 소유자나 승인된 운영자만 호출가능하도록 설정
            msg.sender == owner || _operatorApprovals[owner][msg.sender],
            "not authorized"
        );
        _approvals[_tokenId] = _approved; // _tokenId 토큰에 대한 전송 권한을 _approved 주소에게 부여
        emit Approval(owner, _approved, _tokenId); // Approval 이벤트 발생
    }

    // _operator 주소에 대해 모든 NFT 전송 권한을 위임하거나 철회하는 함수
    function setApprovalForAll(address _operator, bool _approved) external { // _operator에게 모든 토큰에 대한 전송 권한 부여 여부 설정
        _operatorApprovals[msg.sender][_operator] = _approved; // msg.sender의 모든 토큰에 대한 전송 권한을 _operator에게 _approved 여부로 설정
        emit ApprovalForAll(msg.sender, _operator, _approved);
    }

    // 주어진 토큰 ID의 소유권을 다른 주소로 전송하는 함수
    function transferFrom(address _from, address _to, uint256 _tokenId) external payable {
        _transferFrom(_from, _to, _tokenId);
    }

    function _transferFrom(address _from, address _to, uint256 _tokenId) private {
        address owner = _ownerOf[_tokenId]; // _ownerOf를 이용하여 토큰 소유자 얻기
        require(_from == owner, "from!=owner"); // 토큰의 소유자와 from이 같아야 함
        require(_to!=address(0), "transfer to zero address"); // to가 address(0)가 아니어야 함

        // msg.sender는 소유자, 승인된 주소, 운영자여야 함
        require(msg.sender == owner || msg.sender == _approvals[_tokenId] || _operatorApprovals[owner][msg.sender], 
        "msg.sender not in {owner, operator, approved");

        _balanceOf[_from]--; // 보내는 사람 토큰 보유량 감소
        _balanceOf[_to]++; // 받는 사람 토큰 보유량 증가
        _ownerOf[_tokenId] = _to; // _ownerOf를 이용하여 토큰 소유자 변경
        delete _approvals[_tokenId]; // approval 초기화
        emit Transfer(_from, _to, _tokenId); // Transfer 이벤트 발생
    }

    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes calldata data) external payable{
        _transferFrom(_from, _to, _tokenId);

        // 목표 주소가 컨트랙트일 때 onERC721Received 확인
        require(
            _to.code.length == 0 || // 받는 주소에 코드가 없으면 (EOA 지갑)
            ERC721TokenReceiver(_to).onERC721Received(msg.sender, _from, _tokenId, data) == ERC721TokenReceiver(_to).onERC721Received.selector,
            // 컨트랙트면 onERC721Received 호출 후 올바른 selector 반환 확인
            "unsafe recipient" 
        );
    }

    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable{
        _transferFrom(_from, _to, _tokenId);

        // 목표 주소가 컨트랙트일 때 onERC721Received 확인
        require(
            _to.code.length == 0 || // 받는 주소에 코드가 없으면 (EOA 지갑)
            ERC721TokenReceiver(_to).onERC721Received(msg.sender, _from, _tokenId, "") == ERC721TokenReceiver(_to).onERC721Received.selector,
            // 컨트랙트면 onERC721Received 호출 후 올바른 selector 반환 확인
            "unsafe recipient" 
        );
    }

    function supportsInterface(bytes4 interfaceID) external view returns (bool){
        return interfaceID == type(ERC721).interfaceId || // 기본 ERC721 인터페이스 지원
            interfaceID == type(ERC165).interfaceId;
    }
}