//pragma solidity ^0.4.0;
pragma experimental ABIEncoderV2;
contract QuizApp
{
    
    event Print(string _name, address _value);
    event Print1(string _name, uint _value);
    event Print2(address _name, uint _value);
    event Print3(string val);
    
    
    // All set by organizer
    uint participation_fees = 0;
    address organizer_address;
    uint max_num_participant = 0;
    uint organizer_wallet = 0;
    uint current_cnt_of_participant = 0;
    
    
    
    mapping (address => uint) participant_map ;
    mapping (address => uint) participant_current_balanace ;
    mapping (uint => uint) question_answer_map ;
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
        require ( x >= y, " You do'nt have sufficient money to participate ");
        _;
    }
    modifier cnt_participant_threshold(uint x , uint y)
    {
        require ( x < y, " Count Exceeded ");
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
    
    
    // invoked by oarganizer
    constructor (uint fee , uint max_participant , uint[] question_number , uint[] correct_answer  ) public
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
    
    
    // function set_question(uint[] question_number , uint[] correct_answer  ) public
    // is_organizer()
    // validate_question_input(question_number , correct_answer)
    // {
    //     for(uint i=0;i<question_number.length;i++)
    //     {
    //         question_answer_map[question_number[i]] = correct_answer[i];
    //     }
    // }
    
    
    
    
    function regester_as_participant(uint initial_wallet) public
    not_organizer()
    not_participant()
    enough_money(initial_wallet , participation_fees)
    cnt_participant_threshold(current_cnt_of_participant , max_num_participant)
    {
        organizer_wallet += participation_fees ;
        participant_map[msg.sender] = 1 ;
        participant_current_balanace[msg.sender] = initial_wallet - participation_fees ;
        current_cnt_of_participant += 1 ;
    }
    
    
    function play_game_question_answer(uint qno , uint ans) public
    not_organizer()
    is_participant()
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
        
    }
    
    function show_values() public
    {
        
        Print1("organizer_wallet" , organizer_wallet );
        Print2 (msg.sender , participant_current_balanace[msg.sender]);
        
    }
    
    
}
