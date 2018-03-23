pragma solidity ^0.4.18;

contract EtherCardBase {
    // Address of a manager who can set feeAddress
    address public manager;

    // Address to trasfer fee to
    address public feeAddress;

    // This number represents a fee rate in percents multiplied by 1,000,000
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
        bytes32 publicClaimKey;

        // Key to check the validity of a Retrieval Key
        bytes32 publicRetrievalKey;

        // Defines status of a current Card
        CardStatus status;

        // Address of an account who entered Claim Key
        address claimerAddress;
    }

    Card[] public cards;

    function EtherCardBase() public {
        manager = msg.sender;
        feeAddress = msg.sender;
    }

    modifier onlyManager() {
        require(msg.sender == manager);
        _;
    }

    modifier onlyCreatorOf(uint _cardNumber) {
        // Card number must be valid
        require(_cardNumber < cards.length);
        // Check ownership
        require(msg.sender == cards[_cardNumber].creatorAddress);
        _;
    }

    modifier onlyClaimerOf(uint _cardNumber) {
        // Card number must be valid
        require(_cardNumber < cards.length);
        // Check if card is claimed by sender
        require(cards[_cardNumber].status == CardStatus.Claimed);
        require(msg.sender == cards[_cardNumber].claimerAddress);
        _;
    }
}
