pragma solidity >=0.4.22 <0.6.0;

contract Ballot {
    //contract variables
    address owner;
    bytes32 name;
    bytes32 question;
    uint endTime; //time after which no vote can be registered anymore, based on unix epoch
    mapping (bytes32 => bool) m_voterHasVotedWithCodeHash; //hash of the voter's secret code => status (voted or not)
    bool externalitiesEnabled; //to create ballots without controversial externalities
    uint numberOfCandidates; //actually useful
    mapping (uint => s_candidate) m_candidates; //id to candidates
    mapping (uint => uint) m_candidate_poll; //candidate id to his number of votes
    mapping (uint => uint) m_candidate_externality; /* candidate id to the sum of his externalities,
    for penalties or bonus, often used at ISEP */

    //structs definition
    struct s_candidate {
        bytes32 name;
        bytes32 pictureHash; //optional
    }

    constructor(bytes32 _name, bytes32 _question, uint _endTime, bytes32[] _votersHashes, bool _externalitiesEnabled,
        s_candidate[] _candidates) public {
        require(! _name[0] == 0 && ! _question[0] == 0, "name and question must be defined");
        require(_endTime > now, "end time of the ballot must be in the future");
        require(_votersHashes.length >= 2, "no ballot can be created with less than 2 candidates");
        require(! containsIdenticalNames(_candidates), "every candidate's names must be distinct");
        require(! containsIdenticalValues(_votersHashes), "each voter's hashes must bes distinct");

        owner = msg.sender;
        name = _name;
        question = _question;
        endTime = _endTime;
        externalitiesEnabled = _externalitiesEnabled;
        numberOfCandidates = 0; //used as iterator, last value after last while loop will be correct
        while (numberOfCandidates < _candidates.length){
            require(_candidates[numberOfCandidates].name[0] != 0, "every candidate must have a defined name");

            m_candidates[numberOfCandidates] = _candidates[numberOfCandidates];
            numberOfCandidates++;
        }
    }

    //contract core code

    //modifiers
    modifier onlyOwner(){
        require(msg.sender == owner, "function reserved to the contract owner");
    }

    modifier mustBeBeforeEndTime(){
        require(now < endTime, "ballot must still be open");
    }

    modifier checksCandidateId(uint _candidateId){
        require(_candidateId < numberOfCandidates, "candidate id must exist");
    }

    // functions used in constructor checks
    function containsIdenticalNames(s_candidate[] memory _candidates) private pure returns(bool){
        mapping (bytes32 => bool) memory m_names;

        for(uint i = 0; i < _candidates.length; i++){
            if(m_names[_candidates[i].name]){
                return true;
            }
            m_names[_candidates[i].name] = true;
        }
        return false;
    }

    function containsIdenticalValues(bytes32[] memory values) private pure returns(bool){
        mapping (bytes32 => bool) memory m_valueIsUsed;

        for(uint i = 0; i < values.length; i++){
            if(m_valueIsUsed[values[i]]){
                return true;
            }
            m_valueIsUsed[values[i]] = true;
        }
        return false;
    }

    //public methods
    //getters
    function getCandidateScore(uint _candidateId) public view returns(uint){
        return m_candidate_poll[_candidateId] + m_candidate_externality[_candidateId];
    }

    function getCandidateExternality(uint _candidateId) public view returns(uint){
        return m_candidate_externality[_candidateId];
    }

    /* in front, use this value to request every candidate score
    no function "getAllCandidates" is implemented to save gas */
    function getNumberOfCandidates() public view returns(uint){
        return numberOfCandidates;
    }

    function getEndTime() public view returns(uint){
        return endTime;
    }

    function getName() public view returns(bytes32){
        return name;
    }

    function getQuestion() public view returns(bytes32){
        return question;
    }

    //for voters
    function vote(uint _candidateId, bytes32 _voter_code) checksCandidateId mustBeBeforeEndTime public{
        require(! m_voterHasVotedWithCodeHash[keccak256(_voter_code)], "you can only vote once");

        m_candidate_poll[_candidateId]++;
        m_voterHasVotedWithCodeHash[keccak256(_voter_code)] = true;
    }

    //for organiser
    function addNewExternality(uint _candidateId, uint _externality) checksCandidateId onlyOwner public{
        require(externalitiesEnabled, "externalities must be enabled at ballot creation");

        m_candidate_externality[_candidateId] += _externality;
    }
}