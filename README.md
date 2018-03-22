# EtherCard
Ethereum based smart-contract for creating unpersonified cards with monetary value in ETH claimable by third party that is given special key by card's creator.

## How it works
EtherCard Contract works in conjuction with EtherCard Client (https://github.com/shamsfk/EtherCardClient) that is available at ether-card.com.

* Card's Creator specifies an amount of ether that will be attributed to the Card (Card's Value)
* Client generates a pair of random keys:
    * Claiming Key
    * Retrival Key
* Using Claiming Key and Retrival Key (+ Value + Creator's Address) Client generates a new pair of public keys:
    * Public Claiming Key
    * Public Retrival Key
* Amount, Fee Amount, Public Claiming Key, Public Retrival Key and Creator's Address forms the Card
* Card is sent to the Contract by it's Creator
* Creator gives Claiming Key and Retrivat key to a third party (Reciever)
* Reciever enter Claiming Key on the Client and sends in to the Contract
* Contract checks if Claiming Key is valid and locks the Card to Reciver's address (no one else can retrieve ether for it from now on) (* except the Creator who can chancel the Card and get his funds including Fee back any time before it was recieved)
* Reciever checks that Card was indeed claimed to his address and enters Retrival Key that is sent to to the contract
* Contract checks if Retrival Key is valid and transfers Card's Value to the Reciever and Card's Fee to the special address specified by Contract's manager
* Card is closed