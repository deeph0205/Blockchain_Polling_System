pragma solidity ^0.7.0;

contract Polling_System {

    uint256 public number_of_polls = 0;
    mapping(uint => Poll) public List_of_Polls;
    
    struct Poll {
        uint256 set_time;
        string question;
        string choice1;
        uint256 choice1_count;
        string choice2;
        uint256 choice2_count;
        string choice3;
        uint256 choice3_count;
    }
    
    struct User {
        bool voted;  // if true, that person already voted on a poll
        address delegate; // account of person who has voted
        uint vote;   // index of the voted choice
    }

    function createPoll(uint256 _set_time, string memory _question, string memory _choice1,  string memory _choice2,  string memory _choice3 ) public {
        List_of_Polls[number_of_polls + 1].set_time =  _set_time;
        List_of_Polls[number_of_polls + 1].question = _question;
        List_of_Polls[number_of_polls + 1].choice1 = _choice1;
        List_of_Polls[number_of_polls + 1].choice1_count = 0;
        List_of_Polls[number_of_polls + 1].choice2 = _choice2;
        List_of_Polls[number_of_polls + 1].choice2_count = 0;
        List_of_Polls[number_of_polls + 1].choice3 = _choice3;
        List_of_Polls[number_of_polls + 1].choice3_count = 0;
        number_of_polls +=1;
    }
}