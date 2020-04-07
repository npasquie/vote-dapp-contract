pragma solidity >=0.4.22 <0.6.0;

/*
 naming conventions used :
 camelCase
 s_<var_name> for structs
 m_<var_name> for mappings
 _<var_name> for parameters
 may use a convention for arrays in the future
 */

contract Ballot {
    //contract variables
    address owner;
    bytes32 name;
    bytes32 question;
    uint endTime; /* time after which no vote can be registered anymore,
    based on unix epoch */
    mapping (bytes32 => bool) m_voterHasNotYetVotedWithCodeHash;/* turns true in
    constructor for allowed voters, false after vote */
    bool externalitiesEnabled; /* to create ballots without controversial
    externalities */
    bytes32[] candidateNames;
    mapping (bytes32 => s_candidate) m_candidates;

    //structs definition
    struct s_candidate {
        uint poll; //number of votes
        uint externality; //for penalties or bonus, often used at ISEP
        bytes32 pictureHash; //optional
    }

    /* warning : if many candidates with the same name are sent, last one
    will overwrite the others */
    constructor(
        bytes32 _name,
        bytes32 _question,
        uint _endTime,
        bytes32[] memory _votersCodeHashes,
        bool _externalitiesEnabled,
        bytes32[] memory _pictureHashes,
        bytes32[] memory _candidateNames) public {
        require(! (_name[0] == 0) && ! (_question[0] == 0),
          "name and question must be defined");
        require(_endTime > now, "end time of the ballot must be in the future");
        require(_candidateNames.length >= 2,
          "no ballot can be created with less than 2 candidates");

        owner = msg.sender;
        name = _name;
        question = _question;
        endTime = _endTime;
        externalitiesEnabled = _externalitiesEnabled;
        for (uint i = 0; i < _votersCodeHashes.length; i++){
            require(! m_voterHasNotYetVotedWithCodeHash[_votersCodeHashes[i]],
              "each voter's hashes must be distinct");

            m_voterHasNotYetVotedWithCodeHash[_votersCodeHashes[i]] = true;
        }
        candidateNames = new bytes32[](_candidateNames.length);
        for (uint i = 0; i < _candidateNames.length; i++){
            require(_candidateNames[i][0] != 0,
              "every candidate must have a defined name");

            candidateNames[i] = _candidateNames[i];
            m_candidates[_candidateNames[i]].pictureHash = _pictureHashes[i];
        }
    }

    //contract core code

    //modifiers
    modifier onlyOwner(){
        require(msg.sender == owner, "function reserved to the contract owner");
        _;
    }

    modifier mustBeBeforeEndTime(){
        require(now < endTime, "ballot must still be open");
        _;
    }

    //public methods

    //getters
    function getCandidateScore(bytes32 _candidateName)
      public view returns(uint){
        return m_candidates[_candidateName].poll +
          m_candidates[_candidateName].externality;
    }

    function getCandidateExternality(bytes32 _candidateName)
      public view returns(uint){
        return m_candidates[_candidateName].externality;
    }

    function getCandidateNames() public view returns(bytes32[] memory){
        return candidateNames;
    }

    function getCandidatePictureHash(bytes32 _candidateName)
      public view returns(bytes32){
        return m_candidates[_candidateName].pictureHash;
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

    //warning: doesn't check if candidate actually exists
    function vote(bytes32 _candidateName, bytes32 _voterCode)
      mustBeBeforeEndTime public{
        bytes32 voterCodeHash = keccak256(abi.encodePacked(_voterCode));

        require(m_voterHasNotYetVotedWithCodeHash[voterCodeHash],
            "you must be allowed to vote / can only vote once");

        m_candidates[_candidateName].poll++;
        m_voterHasNotYetVotedWithCodeHash[voterCodeHash] = false;
    }

    //warning: doesn't check if candidate actually exists
    function addNewExternality(bytes32 _candidateName, uint _externality)
      onlyOwner mustBeBeforeEndTime public{
        require(externalitiesEnabled,
          "externalities must be enabled at ballot creation");

        m_candidates[_candidateName].externality += _externality;
    }
}
