pragma solidity >=0.4.22 <0.6.0;

contract Ballot {
    //contract variables
    address owner;
    bytes32 name;
    bytes32 question;
    uint endTime; //time after which no vote can be registered anymore, based on unix epoch
    mapping (bytes32 => bool) m_voters; //hash of the voter's secret code => status (voted or not)
    bool externalities_enabled; //to create ballots without controversial externalities
    uint number_of_candidates; //actually useful
    mapping (uint => s_candidate) m_candidates; //id to candidates
    mapping (uint => uint) m_candidate_poll; //candidate id to his number of votes
    mapping (uint => uint) m_candidate_externality; /* candidate id to the sum of his externalities,
    for penalties or bonus, often used at ISEP */

    //structs definition
    struct s_candidate {
        bytes32 name;
        bytes32 pictureHash; //optional
    }

    constructor(bytes32 _name, bytes32 _question, uint _endTime, bytes32[] _voters_hashes, bool _externalities_enabled,
        s_candidate[] _candidates) public {
        require(_endTime > block.timestamp, "end time of the ballot is in the past");
        require(_voters_hashes.length >= 2, "not ballot can be created with less than 2 candidates");

        uint

        owner = msg.sender;
        name = _name;
        question = _question;
        for (uint i = 0; i < _voters_hashes.length; i++){
            m_voters[_voters_hashes[i]] = false;
        }
        externalities_enabled = _externalities_enabled;
        number_of_candidates = 0; //used as iterator, last value after last while loop will be correct
        while (number_of_candidates < _candidates.length){
            require(_candidates[number_of_candidates].name != 0, "every candidate must have a defined name");

            m_candidates[number_of_candidates] = _candidates[number_of_candidates];
            number_of_candidates++;
        }
    }

    //contract core code

}