pragma solidity ^0.4.18;

//todo: randomization using oracle
contract Raffles {

    address private admin;
    mapping(address => Winner) winners;


    modifier onlyAdmin() {
        require(msg.sender == admin);
        _;
    }

    constructor() public {
        admin = msg.sender;
    }

    struct Raffle {
        uint id;
        uint goal;
        uint numberOfParticipants;
        bool closed;
        address[] players;
        Winner winner;
        mapping(address => Player) player;
    }

    Raffle[300] public raffles;

    struct Player {
        address id;
        bytes32 firstName;
        bytes32 lastName;
        string email;
        string college;
        string major;
        // string ipfsHash;
        bool registered;
    }

    struct Winner {
        uint amount;
        address id;
        bytes32 firstName;
        bytes32 lastName;
        string email;
        string college;
        string major;
    }

    // function saveHash(string _ipfsHash, uint raffleId) public {
    //     raffles[raffleId].raffle[msg.sender].ipfsHash = _ipfsHash;
    // }

    event registered(uint indexed _id);
    event runRaffle(bool _trigger);

    function register(bytes32 _firstName, bytes32 _lastName,
                      string _email, string _college,
                      string _major, uint _id, uint _goal) public {

        //check if raffle is open -> should happen on front end using a disable button if closed is set to true
        require(raffles[_id].closed == false);

        //check if player limit is reached
        require(raffles[_id].numberOfParticipants <= 50);

        //check if user has registered before
        require(raffles[_id].player[msg.sender].registered == false);


        if(raffles[_id].numberOfParticipants == 50)
        {
            raffles[_id].closed = true;

            //send event to client
            emit runRaffle(true);
        }
        else
        {

            //create  new player
            Player memory currentPlayer = Player(msg.sender, _firstName, _lastName, _email, _college, _major, true);

            //store the player's properties
            raffles[_id].player[msg.sender] = currentPlayer;

            //update the raffle's properties
            raffles[_id].numberOfParticipants += 1;

            if(raffles[_id].goal == 0)
            {
                raffles[_id].goal = _goal;
            }

            //push the user into the array of players from the Raffle struct
            raffles[_id].players.push(msg.sender);

            //send event to client
            emit registered(_id);
        }
    }

    function getRaffle(uint _id) public constant returns (uint ,uint, bool, address[]) {
        return (raffles[_id].id,
                raffles[_id].goal,
                raffles[_id].closed,
                raffles[_id].players);

        getWinner(_id);

    }



    // function getPlayer(uint _raffleId, address _id) public constant returns (bytes32, bytes32, string, string, string, bool) {
    //     return (raffles[_raffleId].player[_id].firstName,
    //             raffles[_raffleId].player[_id].lastName,
    //             raffles[_raffleId].player[_id].email,
    //             raffles[_raffleId].player[_id].college,
    //             raffles[_raffleId].player[_id].major,
    //             raffles[_raffleId].player[_id].registered);

    // }

    //call from client to store random number
    function declareWinner(uint _winnerId, uint _raffleId) private onlyAdmin returns (address, bytes32, bytes32, string, string, string) {

        address winnerAddress = raffles[_raffleId].players[_winnerId];

        Player memory playerStruct = raffles[_raffleId].player[winnerAddress];

        winners[winnerAddress] = Winner(raffles[_raffleId].goal,
                                                playerStruct.id,
                                                playerStruct.firstName,
                                                playerStruct.lastName,
                                                playerStruct.email,
                                                playerStruct.college,
                                                playerStruct.major);

        raffles[_raffleId].winner = Winner(raffles[_raffleId].goal,
                                           raffles[_raffleId].player[winnerAddress].id,
                                           raffles[_raffleId].player[winnerAddress].firstName,
                                           raffles[_raffleId].player[winnerAddress].lastName,
                                           raffles[_raffleId].player[winnerAddress].email,
                                           raffles[_raffleId].player[winnerAddress].college,
                                           raffles[_raffleId].player[winnerAddress].major);

        getWinner(_raffleId);

    }

    //once raffle is over, admin can call this funtion to get winner's details
    function getWinner(uint _raffleId) public constant onlyAdmin returns (address, bytes32, bytes32, string, string, string) {

            return (raffles[_raffleId].winner.id,
                    raffles[_raffleId].winner.firstName,
                    raffles[_raffleId].winner.lastName,
                    raffles[_raffleId].winner.email,
                    raffles[_raffleId].winner.college,
                    raffles[_raffleId].winner.major
                    );
    }

    function contractdisable() public onlyAdmin {
        require (admin == msg.sender);
        selfdestruct(admin);
    }

}

