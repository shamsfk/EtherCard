pragma solidity ^0.4.18;

contract EtherCard {
    
    // Address of manager who can set feeAddress
    address public manager;
    
    // Address to trasfer fee to
    address public feeAddress;
    
    // This number represents a fee rate in percents / 10
    uint public constant FEE_RATE = 5; // 0.5%
    
    enum CardStatus {
        Waiting,
        Claimed,
        Retrieved,
        Chancelled
    }

    struct Card {
        // Who created a Card
        address creatorAddress;
        
        // How much ether in wei card holds
        uint value;
        
        // How much fee in wei card holds
        uint fee;

        // Key to check the validity of a Claim Key
        string publicClaimKey;

        // Key to check the validity of a Retrival Key
        string publicRetrivalKey;
        
        // Defines status of a current Card
        CardStatus status;
        
        // Address of an account who entered Claim Key
        address claimerAddress;
    }
    
    Card[] public cards;
    
    function EtherCard(address _feeAddress) public {
        manager = msg.sender;
        feeAddress = _feeAddress;
    }
    
    function changeFeeAddress(address _newFeeAdress) public {
        // Only manager can change Fee Address
        require(msg.sender == manager);
        feeAddress = _newFeeAdress;
    }

    function createCard(uint _value, string _claimKey, string _retrivalKey) public payable {
        // Check if value and fee are fair
        require((_value * 10 / 100) * FEE_RATE == msg.value - _value);
        
        Card memory newCard = Card(msg.sender, _value, (msg.value-_value), _claimKey, _retrivalKey, CardStatus.Waiting, 0);
        
        cards.push(newCard);
    }
    
    function cancelCard(uint _cardNumber) public payable {
        // Card number must be valid
        require(_cardNumber < cards.length);
        
        require(msg.sender == cards[_cardNumber].creatorAddress);
        
        // TODO: return all the money to card's creator (including fee)
        
        cards[_cardNumber].status = CardStatus.Chancelled;
    }
    
    function claimCard(uint _cardNumber, uint _controlKey) public payable {
        // Card number must be valid
        require(_cardNumber < cards.length);
        
        // Card mast be in th waiting state
        require(cards[_cardNumber].status == CardStatus.Waiting);
        
        // TODO: Check if _controlKey is valid
        require(_controlKey == 0);
        
        cards[_cardNumber].claimerAddress = msg.sender;
        cards[_cardNumber].status = CardStatus.Claimed;
    }
    
    /// @dev s
    /// @param _cardNumber s
    /// @param _retrivalKey s
    /// @notice client app should check if card is controlled by the retriever
    ///         using checkOwnership() before sending Retrival Key into the wild
    function retrieveCard(uint _cardNumber, uint _retrivalKey) public payable {
        // Card number must be valid
        require(_cardNumber < cards.length);
        
        // Card mast be controlled by the same person who tries to retrieve it
        require(cards[_cardNumber].status == CardStatus.Claimed);
        require(msg.sender == cards[_cardNumber].claimerAddress);
        
        // TODO: Check if _retrivalKey is valid
        require(_retrivalKey == 0);
        
        // TODO: transfer value to customer
        // TODO: transfer fee to manager
        
        cards[_cardNumber].status = CardStatus.Retrieved;
    }
}