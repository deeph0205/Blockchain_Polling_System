// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.7.0;

contract Polling_System {

    uint256 public number_of_polls = 0;
    uint256 public number_of_users = 0;
    address public owner;

    mapping(uint256 => User) public Users;
    mapping(uint256 => Poll) public List_of_Polls;
    
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

    constructor() {
        owner = msg.sender;
        Users[number_of_users + 1].voted = false;
        Users[number_of_users + 1].delegate = owner;
        Users[number_of_users + 1].vote = 100;
        number_of_users +=1;
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

    function addVote(uint256 _select_poll, uint256 _select_choice) public {
        require(_select_choice <= 3, "Please choose a choice between numbers 1 and 3");
        require(_select_poll <= number_of_polls, "Please choose a correct Poll number to vote");
        if(_select_choice == 1) {
            List_of_Polls[_select_poll].choice1_count += 1;
        }
        if(_select_choice == 2) {
            List_of_Polls[_select_poll].choice2_count += 1;
        }
        if(_select_choice == 3) {
            List_of_Polls[_select_poll].choice3_count += 1;
        }

    }

    function displayWinner(uint256 _select_poll) public view returns (string memory)  {
        require(_select_poll <= number_of_polls, "Please choose a correct Poll number to Display winner");
        uint256 max_count = 0;
        string memory max_string;
        if(List_of_Polls[_select_poll].choice1_count > max_count) {
            max_count = List_of_Polls[_select_poll].choice1_count;
            max_string = List_of_Polls[_select_poll].choice1;
        }
        if(List_of_Polls[_select_poll].choice2_count > max_count) {
            max_count = List_of_Polls[_select_poll].choice2_count;
            max_string = List_of_Polls[_select_poll].choice2;
        }
        if(List_of_Polls[_select_poll].choice3_count > max_count) {
            max_count = List_of_Polls[_select_poll].choice3_count;
            max_string = List_of_Polls[_select_poll].choice3;
        }
        return max_string;

    }
}
