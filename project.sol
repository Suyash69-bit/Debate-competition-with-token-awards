// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract DebateCompetition {
    string public name = "DebateCompetitionToken";
    string public symbol = "DCT";
    uint8 public decimals = 18;
    uint256 public totalSupply;

    address public owner;
    mapping(address => uint256) public balances;
    mapping(address => mapping(address => uint256)) public allowed;
    mapping(address => uint256) public participantScores;
    
    // Event to log transfers
    event Transfer(address indexed from, address indexed to, uint256 value);
    // Event for token approval
    event Approval(address indexed owner, address indexed spender, uint256 value);
    // Event to log score updates
    event ScoreUpdated(address indexed participant, uint256 score);
    
    // Modifier to restrict functions to the owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    // Constructor to initialize the contract
    constructor(uint256 _initialSupply) {
        owner = msg.sender;
        totalSupply = _initialSupply * 10 ** uint256(decimals);
        balances[owner] = totalSupply;
    }

    // Transfer tokens to a specific address
    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balances[msg.sender] >= _value, "Insufficient balance");
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    // Allow spender to transfer tokens on behalf of the owner
    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    // Transfer tokens from a spender to a recipient
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(balances[_from] >= _value, "Insufficient balance");
        require(allowed[_from][msg.sender] >= _value, "Allowance exceeded");
        balances[_from] -= _value;
        balances[_to] += _value;
        allowed[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
        return true;
    }

    // Update the score for a participant (could be based on voting, judges, etc.)
    function updateScore(address _participant, uint256 _score) public onlyOwner {
        participantScores[_participant] = _score;
        emit ScoreUpdated(_participant, _score);
    }

    // Reward tokens to the participant based on their score
    function rewardTokens(address _participant) public onlyOwner {
        uint256 score = participantScores[_participant];
        require(score > 0, "No score recorded for participant");

        // Example: Rewarding 10 tokens for every 1 point scored
        uint256 rewardAmount = score * 10 ** uint256(decimals);
        require(balances[owner] >= rewardAmount, "Insufficient balance to reward");

        balances[owner] -= rewardAmount;
        balances[_participant] += rewardAmount;
        emit Transfer(owner, _participant, rewardAmount);
    }

    // Function to check balance of an address
    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }

    // Function to check the score of a participant
    function getScore(address _participant) public view returns (uint256) {
        return participantScores[_participant];
    }
}

