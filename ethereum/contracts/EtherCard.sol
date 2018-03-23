pragma solidity ^0.4.18;

import {EtherCardBase} from "./EtherCardBase.sol";

contract EtherCard is EtherCardBase {
    /// @notice Changes address to transfer fee to
    /// @param _newFeeAddress New address
    /// @author Bulat Shamsutdinov (shamsfk)
    function changeFeeAddress(address _newFeeAddress) external onlyManager {
        feeAddress = _newFeeAddress;
    }

    /// @notice Create a card and transfer it's value and fee to the Contract to hold
    /// @param _value What amount of ether will reciever of a card get 
    /// @param _fee A fee to the contract's creator shoud be _value * 0.353236% + 1 wei
    /// @param _claimKey Public ClaimKey that will be used to check the validity of a private one
    /// @param _retrievalKey Public RetrievalKey that will be used to check the validity of a private one
    /// @author Bulat Shamsutdinov (shamsfk)
    function createCard(uint _value, uint _fee, bytes32 _claimKey, bytes32 _retrievalKey) external payable {
        // Check if fee is fair
        require(_value + _fee <= msg.value);
        require(_value * FEE_RATE / 100000000 <= _fee);
        
        // Create and store new card
        Card memory newCard = Card(msg.sender, _value, _fee, _claimKey, _retrievalKey, CardStatus.Waiting, 0);
        cards.push(newCard);
    }
    
    /// @notice Cancel card and retrieve both it's value and fee
    /// (only card's creator can cancel).
    /// @param _cardNumber Number of a card to cancel
    /// @author Bulat Shamsutdinov (shamsfk)
    function cancelCard(uint _cardNumber) external onlyCreatorOf(_cardNumber) {        
        // Return all the money to card's creator (including fee)
        cards[_cardNumber].creatorAddress.transfer(cards[_cardNumber].value + cards[_cardNumber].fee);
        cards[_cardNumber].status = CardStatus.Chancelled;
    }
    
    /// @notice Claim the Card using ClaimKey effectively locking
    /// it to msg.sender address (the only address able to retrieve)
    /// @param _cardNumber Number of a card to claim
    /// @param _claimKey Private Key to prove the right to claim
    /// @author Bulat Shamsutdinov (shamsfk)
    function claimCard(uint _cardNumber, bytes32 _claimKey) external {
        // Card number must be valid
        require(_cardNumber < cards.length);
        
        // Card mast be in th waiting state
        require(cards[_cardNumber].status == CardStatus.Waiting);
        
        // TODO: Check if _controlKey is valid
        require(keccak256(_claimKey) == cards[_cardNumber].publicClaimKey);
        
        cards[_cardNumber].claimerAddress = msg.sender;
        cards[_cardNumber].status = CardStatus.Claimed;
    }

    /// @notice Checks if msg.sender has successfully claimed the Card
    /// @param _cardNumber Number of a card to check
    /// @return Returns true if msg.sender claimed the card and false otherwise
    /// @author Bulat Shamsutdinov (shamsfk)
    function isCardClaimedByMe(uint _cardNumber) external view returns(bool) {
        return (cards[_cardNumber].claimerAddress == msg.sender);
    }
    
    /// @notice Retrieve card's funds using RetrivalKey
    /// (only address that claimed card can retrieve it's funds)
    /// @param _cardNumber Number of a card to retrieve
    /// @param _retrievalKey Private Key to prove the right to retrieve
    /// @dev client app should check if card is controlled by the retriever
    /// using checkOwnership() before sending Retrival Key into the wild
    /// @author Bulat Shamsutdinov (shamsfk)
    function retrieveCard(uint _cardNumber, bytes32 _retrievalKey) external onlyClaimerOf(_cardNumber) {        
        // TODO: Check if _retrievalKey is valid
        require(keccak256(_retrievalKey) == cards[_cardNumber].publicRetrievalKey);
        
        // Transfer value to claimerAddress
        cards[_cardNumber].claimerAddress.transfer(cards[_cardNumber].value);

        // Transfer fee to feeAddress
        feeAddress.transfer(cards[_cardNumber].fee);
        
        // Close card by changing status to Retrieved 
        cards[_cardNumber].status = CardStatus.Retrieved;
    }
}