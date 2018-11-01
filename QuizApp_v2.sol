    //pragma solidity ^0.4.0;
    pragma experimental ABIEncoderV2;
    contract QuizApp
    {
     
        event Print(string _name, address _value);
        event Print1(string _name, uint _value);
        event Print2(address _name, uint _value);
        event Print3(string val);
        event Print4(uint val);
     
     
        // All set by organizer
        uint participation_fees = 0;
        address organizer_address;
        uint max_num_participant = 0;
        uint organizer_wallet = 0;
        uint current_cnt_of_participant = 0;
        
     
     
        mapping (address => uint) participant_map ;
        mapping (address => uint) participant_current_balanace ;
        mapping (uint => uint) question_answer_map ;
        mapping( address => uint )participant_withdraw_money;
        mapping( address => uint )participant_answered_questions;
        
        modifier not_organizer()
        {
            require ( msg.sender != organizer_address , " You are already regestered as an organizer ");
            _;
        }
        modifier is_organizer()
        {
            require ( msg.sender == organizer_address , " You NOT regestered as an organizer ");
            _;
        }
        modifier not_participant()
        {
            require ( participant_map[msg.sender] != 1, " You are already regestered as a participant ");
            _;
        }
         modifier is_participant()
        {
            require ( participant_map[msg.sender] == 1, " You are NOT regestered as a participant ");
            _;
        }
        modifier enough_money(uint x , uint y)
        {
            
            require ( x == y, " you should provide equal money as praticipation fees ");
            _;
        }
        modifier cnt_participant_threshold(uint x , uint y)
        {
            require ( x < y, " Count Exceeded ");
            _;
        }
        
        modifier has_already_withdraw()
        {
           
            
            require ( participant_withdraw_money[msg.sender] != 1, " You have already wwithdrawn money ");
            _;
        }
        
        modifier validate_question_input(uint[] question_number , uint[] correct_answer)
        {
            require(question_number.length == correct_answer.length , "Lenght mismatch : Incorrect input");_;
            for (uint i =0;i<question_number.length;i++)
            {
                require(question_number[i]<5 , "invalid qustion number in input");_;
                require(correct_answer[i]<=4 , "invalid correct answer in input");_;
            }
            for (i =1 ;i<=4;i++)
            {
                uint temp =0;
                for (uint j =0;j<question_number.length;j++)
                {
                    if(question_number[j]==i)
                    {
                        temp ++;
                    }
                }
                require(temp ==1 , "either question repeated or it is absent ");_;
            }
     
     
        }
        
        
        modifier is_already_answered(uint tqno)
        {
            if(tqno ==3 )
            {
                tqno = 4;
            }
            else if(tqno ==4)
            {
                tqno = 8;
            }
            
            require ( ( participant_answered_questions[msg.sender]&tqno ) == 0 , " You have already answered this question ");
            _;
        }
     
     
        // invoked by oarganizer
        constructor (uint fee , uint max_participant , uint[] question_number , uint[] correct_answer  ) public payable
        validate_question_input(question_number , correct_answer)
        {
            participation_fees = fee;
            max_num_participant = max_participant ;
            organizer_address = msg.sender;
            Print("organizer " , organizer_address);
     
            for(uint i=0;i<question_number.length;i++)
            {
                question_answer_map[question_number[i]] = correct_answer[i];
            }
        }
   
     
        function regester_as_participant() public payable
        not_organizer()
        not_participant()
        enough_money(msg.value , participation_fees)
        cnt_participant_threshold(current_cnt_of_participant , max_num_participant)
        {
            
            organizer_wallet += participation_fees ;
            participant_map[msg.sender] = 1 ;
            participant_current_balanace[msg.sender] = msg.value - participation_fees ;
            current_cnt_of_participant += 1 ;
            participant_answered_questions[msg.sender] = 0;
        }

        function get_current_participant_count() public view returns(uint){
            return current_cnt_of_participant;
        }     
     
        function play_game_question_answer(uint qno , uint ans) public
        not_organizer()
        is_participant()
        is_already_answered(qno)
        {
            if(question_answer_map[qno]==ans)
            {
                participant_current_balanace[msg.sender] += (organizer_wallet/16);
                Print3("Correct Answer");
            }
            else
            {
                Print3("Wrong Answer");
            }
            uint value_answered = qno;
            if(value_answered ==3)
            {
                value_answered =4;
            }
            else if (value_answered ==4)
            {
                value_answered = 8;
            }
            uint previous_value = participant_answered_questions[msg.sender];
            participant_answered_questions[msg.sender] = (previous_value | value_answered);
     
        }

        function withdraw_balance() public  payable // used by participant to withdraw reward
        not_organizer()
        is_participant()
        has_already_withdraw()
        returns(uint)
        {
            (organizer_address).transfer(participant_current_balanace[msg.sender]);
            return participant_current_balanace[msg.sender];
        } 
        
        function show_reward() public view returns(uint)
        {
            return (organizer_wallet/16);
        }
        
        function show_values() public payable
        {
     
            Print1("organizer_wallet" , organizer_wallet );
            Print2 (msg.sender , participant_current_balanace[msg.sender]);
            (msg.sender).transfer(participant_current_balanace[msg.sender]);
     
        }
        function getBalance() public  view // used by organizer to see contract balance 
        not_participant()
        is_organizer()
         returns (uint256)
        {
            return address(this).balance;
        }
        function temp(uint qno) public 
        {
            Print4(participant_answered_questions[msg.sender]);
            Print4(qno);
        }
     
     
    }
    
    // 10,3,[1,2,3,4],[1,2,3,4]
    
    
