pragma solidity ^0.4.21;

contract EtherCard {
    
    // Address of a manager who can set feeAddress
    address public manager;
    
    // Address to trasfer fee to
    address public feeAddress;
    
    // This number represents a fee rate in percents / 1,000,000
    uint public constant FEE_RATE = 353236; // 0.353236%
    
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
    
    /// @notice Changes address to transfer fee to
    /// @param _newFeeAddress New address
    /// @author Bulat Shamsutdinov (shamsfk)
    function changeFeeAddress(address _newFeeAddress) public {
        // Only manager can change Fee Address
        require(msg.sender == manager);
        feeAddress = _newFeeAddress;
    }

    /// @notice Create a card and transfer it's value and fee to the Contract to hold
    /// @param _value What amount of ether will reciever of a card get 
    /// @param _fee A fee to the contract's creator shoud be _value * 0.353236% + 1 wei
    /// @param _claimKey Public ClaimKey that will be used to check the validity of a private one
    /// @param _retrivalKey Public RetrivalKey that will be used to check the validity of a private one
    /// @author Bulat Shamsutdinov (shamsfk)
    function createCard(uint _value, uint _fee, string _claimKey, string _retrivalKey) public payable {
        // Check if fee is fair
        require(_value + _fee <= msg.value);
        require(_value * FEE_RATE / 10000 <= _fee);
        
        // Create and store new card
        Card memory newCard = Card(msg.sender, _value, _fee, _claimKey, _retrivalKey, CardStatus.Waiting, 0);
        cards.push(newCard);
    }

    // TODO: move require(_cardNumber < cards.length) to modifier
    
    /// @notice Cancel card and retrieve both it's value and fee
    /// (only card's creator can cancel).
    /// @param _cardNumber Number of a card to cancel
    /// @author Bulat Shamsutdinov (shamsfk)
    function cancelCard(uint _cardNumber) public {
        // Card number must be valid
        require(_cardNumber < cards.length);
        
        require(msg.sender == cards[_cardNumber].creatorAddress);
        
        // TODO: return all the money to card's creator (including fee)
        
        cards[_cardNumber].status = CardStatus.Chancelled;
    }
    
    /// @notice Claim the Card using ClaimKey effectively locking
    /// it to msg.sender address (the only address able to retrieve)
    /// @param _cardNumber Number of a card to claim
    /// @param _claimKey Private Key to prove the right to claim
    /// @author Bulat Shamsutdinov (shamsfk)
    function claimCard(uint _cardNumber, uint _claimKey) public {
        // Card number must be valid
        require(_cardNumber < cards.length);
        
        // Card mast be in th waiting state
        require(cards[_cardNumber].status == CardStatus.Waiting);
        
        // TODO: Check if _controlKey is valid
        require(_claimKey == 0);
        
        cards[_cardNumber].claimerAddress = msg.sender;
        cards[_cardNumber].status = CardStatus.Claimed;
    }

    /// @notice Checks if msg.sender has successfully claimed the Card
    /// @param _cardNumber Number of a card to check
    /// @return Returns true if msg.sender claimed the card and false otherwise
    /// @author Bulat Shamsutdinov (shamsfk)
    function isCardClaimedByMe(uint _cardNumber) public view returns(bool) {
        return (cards[_cardNumber].claimerAddress == msg.sender);
    }
    
    /// @notice Retrieve card's funds using RetrivalKey
    /// (only address that claimed card can retrieve it's funds)
    /// @param _cardNumber Number of a card to retrieve
    /// @param _retrivalKey Private Key to prove the right to retrieve
    /// @dev client app should check if card is controlled by the retriever
    /// using checkOwnership() before sending Retrival Key into the wild
    /// @author Bulat Shamsutdinov (shamsfk)
    function retrieveCard(uint _cardNumber, uint _retrivalKey) public {
        // Card number must be valid
        require(_cardNumber < cards.length);
        
        // Card mast be controlled by the same person who tries to retrieve it
        require(cards[_cardNumber].status == CardStatus.Claimed);
        require(msg.sender == cards[_cardNumber].claimerAddress);
        
        // TODO: Check if _retrivalKey is valid
        require(_retrivalKey == 0);
        
        // Transfer value to claimerAddress
        cards[_cardNumber].claimerAddress.transfer(cards[_cardNumber].value);

        // Transfer fee to feeAddress
        feeAddress.transfer(cards[_cardNumber].fee);
        
        // Close card by changing status to Retrieved 
        cards[_cardNumber].status = CardStatus.Retrieved;
    }
}