// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract Ballot {
    struct Voter {
        uint weight;
        bool voted;
        uint vote;
    }
    struct Proposal {
        uint voteCount;
    }

    address public chairperson;

    mapping(address => Voter) public voters;
    
    Proposal[] public proposals;


    modifier onlyChair() {
        require(msg.sender == chairperson, "Only chairperson can call this.");
        _;
    }

    modifier validVoter() {
        require(voters[msg.sender].weight > 0, "Not a registered voter.");
        _;
    }

    constructor(uint numProposals) {
        chairperson = msg.sender;
        voters[chairperson].weight = 1;
        for (uint i = 0; i < numProposals; i++) {
            proposals.push(Proposal(0));
        }
    }


    function register(address voter) public onlyChair {
        
        if (voter == msg.sender){
            voters[voter].weight = 2;
        }
        voters[voter].weight = 1;
    }

    function vote(uint proposal) public validVoter {

        require(!voters[msg.sender].voted, "Already voted.");
        voters[msg.sender].voted = true;
        voters[msg.sender].vote = proposal;
        proposals[proposal].voteCount += voters[msg.sender].weight;
    }


    function regWinner() public view returns(uint) {
        uint max = 0;
        uint i =0;
        for (i=0; i< proposals.length; i++){
            if(proposals[i].voteCount > max){
                max = i;
            }
        }
        return i;
    }
}
