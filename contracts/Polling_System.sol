// SPDX-License-Identifier: GPL-3.0
// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.5.0;

// Smart contract for Polling System;

contract Polling_System {

    uint256 public number_of_polls = 0;         // Total number of polls created;
    uint256 public number_of_users = 0;         // Total number of users;
//    uint256 public past;
    address public owner;

    mapping(address => User) public Users;
    mapping(uint256 => Poll) public List_of_Polls;
    
    struct Poll {
        uint256 set_time;
        uint256 created_time;                       // Time the poll lasts
        bool is_active;
        string question;                        // Question for poll
        string choice1;                         // Three choices with their count information
        uint256 choice1_count;
        string choice2;
        uint256 choice2_count;
        string choice3;
        uint256 choice3_count;
    }
    
    struct User {
        bool voted;  // If true, that person already voted on a poll
    }

    // Initialize when the smart contract is deployed
    
    constructor() public {
        owner = msg.sender;                     // Assign the owner rights to the person who deploys the contract
        Users[msg.sender].voted = false;
        number_of_users +=1;
    }
    

    // Interface for displayWinner
    function displayWinner(uint256 _select_poll) public view returns (string memory)  {

        require(_select_poll <= number_of_polls, "Please choose a correct Poll number to Display winner");
        uint256 max_count = 0;
        string memory max_string;

        if(List_of_Polls[_select_poll].choice1_count!= 0 || List_of_Polls[_select_poll].choice2_count!= 0 || List_of_Polls[_select_poll].choice3_count!= 0 ) {
            
            if(List_of_Polls[_select_poll].choice1_count != List_of_Polls[_select_poll].choice2_count && List_of_Polls[_select_poll].choice1_count != List_of_Polls[_select_poll].choice3_count && List_of_Polls[_select_poll].choice3_count != List_of_Polls[_select_poll].choice2_count ) {

                if(List_of_Polls[_select_poll].choice1_count >= max_count) {    // by default we set our winner to first choice
                    max_count = List_of_Polls[_select_poll].choice1_count;
                    max_string = List_of_Polls[_select_poll].choice1;
                }
                if(List_of_Polls[_select_poll].choice2_count > max_count) {     // Conditions to see if we have other winners
                    max_count = List_of_Polls[_select_poll].choice2_count;
                    max_string = List_of_Polls[_select_poll].choice2;
                }
                if(List_of_Polls[_select_poll].choice3_count > max_count) {
                    max_count = List_of_Polls[_select_poll].choice3_count;
                    max_string = List_of_Polls[_select_poll].choice3;
                }
                return max_string;

            }

            //  A = B !=C
            else if (List_of_Polls[_select_poll].choice1_count == List_of_Polls[_select_poll].choice2_count && List_of_Polls[_select_poll].choice1_count != List_of_Polls[_select_poll].choice3_count) {
                if(List_of_Polls[_select_poll].choice1_count > List_of_Polls[_select_poll].choice3_count) {
                    revert("There is a tie between wining Choices 1 and 2, required to break the tie");
                }
                else {
                   max_string = List_of_Polls[_select_poll].choice3;
                   return max_string; 
                }
            }

            // B = C != A
            else if (List_of_Polls[_select_poll].choice3_count == List_of_Polls[_select_poll].choice2_count && List_of_Polls[_select_poll].choice1_count != List_of_Polls[_select_poll].choice3_count) {
                if(List_of_Polls[_select_poll].choice3_count > List_of_Polls[_select_poll].choice1_count) {
                    revert("There is a tie between wining Choices 2 and 3, required to break the tie");
                }
                else {
                   max_string = List_of_Polls[_select_poll].choice1;
                   return max_string; 
                }
            }
            
            // A = C != B
            else if (List_of_Polls[_select_poll].choice1_count == List_of_Polls[_select_poll].choice3_count && List_of_Polls[_select_poll].choice1_count != List_of_Polls[_select_poll].choice2_count) {
                if(List_of_Polls[_select_poll].choice1_count > List_of_Polls[_select_poll].choice2_count) {
                    revert("There is a tie between wining Choices 1 and 3, required to break the tie");
                }
                else {
                   max_string = List_of_Polls[_select_poll].choice2;
                   return max_string; 
                }
            }

            else {
                revert("There is a tie between wining Choices 1, 2 and 3, required to break the tie");
            }
        }
        else{
            revert("There have been no votes on the given poll");
        }

    }

    function checkpoll(uint256 _select_poll) public returns (bool) {
        if (block.timestamp >= (List_of_Polls[_select_poll].set_time + List_of_Polls[_select_poll].created_time)) {
            List_of_Polls[_select_poll].is_active = false;
        }
        return List_of_Polls[_select_poll].is_active;
    }

    // Interface for creating a poll

    function createPoll(uint256 _set_time, string memory _question, string memory _choice1,  string memory _choice2,  string memory _choice3 ) public {
        List_of_Polls[number_of_polls + 1].set_time =  _set_time;
        List_of_Polls[number_of_polls + 1].created_time = block.timestamp;
        List_of_Polls[number_of_polls + 1].is_active = true;
        List_of_Polls[number_of_polls + 1].question = _question;
        List_of_Polls[number_of_polls + 1].choice1 = _choice1;
        List_of_Polls[number_of_polls + 1].choice1_count = 0;
        List_of_Polls[number_of_polls + 1].choice2 = _choice2;
        List_of_Polls[number_of_polls + 1].choice2_count = 0;
        List_of_Polls[number_of_polls + 1].choice3 = _choice3;
        List_of_Polls[number_of_polls + 1].choice3_count = 0;
        number_of_polls +=1;

    }

    // Interface for adding vote on a poll

    function addVote(uint256 _select_poll, uint256 _select_choice) public {
        
        require(checkpoll(_select_poll) == true, "Poll has already expired, select another poll to vote");
        require(!Users[msg.sender].voted, "You have already voted");
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

        Users[msg.sender].voted = true;

    }

    
}