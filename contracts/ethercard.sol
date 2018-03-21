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
        Controlled,
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
        
        // Defines status of a current Card
        CardStatus status;
        
        // Address of an account who entered Control Key
        address controlKeyAddress;
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

    function makeCard(uint _value) public payable {
        // Check if value and fee are fair
        require((_value * 10 / 100) * FEE_RATE == msg.value - _value);
        
        Card memory newCard = Card({
            creatorAddress:msg.sender, 
            value:_value, 
            fee:(msg.value-_value), 
            status:CardStatus.Waiting,
            controlKeyAddress:0
        });
        
        cards.push(newCard);
    }
    
    function cancelCard(uint _cardNumber) public payable {
        // Card number must be valid
        require(_cardNumber < cards.length);
        Card storage card = cards[_cardNumber];
        
        require(msg.sender == card.creatorAddress);
        
        // TODO: return all the money to card's creator (including fee)
        
        card.status = CardStatus.Chancelled;
    }
    
    function controlCard(uint _cardNumber, uint _controlKey) public payable {
        // Card number must be valid
        require(_cardNumber < cards.length);
        Card storage card = cards[_cardNumber];
        
        // Card mast be in th waiting state
        require(card.status == CardStatus.Waiting);
        
        // TODO: Check if _controlKey is valid
        
        card.controlKeyAddress = msg.sender;
        card.status = CardStatus.Controlled;
    }
    
    /// @dev
    /// @param
    /// @param
    /// @notice client app should check if card is controlled by the retriever
    ///         using checkOwnership() before sending Retrival Key into the wild
    function retrieveCard(uint _cardNumber, uint _retrivalKey) public payable {
        // Card number must be valid
        require(_cardNumber < cards.length);
        Card storage card = cards[_cardNumber];
        
        // Card mast be controlled by the same person who tries to retrieve it
        require(card.status == CardStatus.Controlled);
        require(msg.sender == card.controlKeyAddress);
        
        // TODO: Check if _retrivalKey is valid
        
        // TODO: transfer value to customer
        // TODO: transfer fee to manager
        
        card.status = CardStatus.Retrieved;
    }
}