# EtherCard
Ethereum contract to create and share unpersonified gift cards that will someday be available at https://ether-card.com

## What is it for
The main purpose of EtherCard is to create a gift card with some amount of ether to be given to somebody you don't want to ask for their address beforehand or you would like to surprise by presenting a card at some exact moment.

_Prepaid accounts can be and are used for the same purpose, the only value of EtherCard is in the retrieval process itself and a specific purpose of it which symbolizes a gift._

## How it works
1. Card's Creator specifies an amount of ether that will be attributed to the Card (Card's Value) and a special text message (Card's Text)
2. Using random number generator, Creator's address, current time and SHA256 algorithm Client generates a pair of private keys:
    * Claiming Key
    * Retrieval Key
3. Using Claiming Key, Retrieval Key and SHA256 algorithm Client generates a pair of public keys:
    * Public Claiming Key
    * Public Retrieval Key
4. An Amount, FeeAmount*, PublicClaimingKey, PublicRetrievalKey, Card's Text and Creator's Address forms the Card
5. The card is sent to the Contract, Contract stores the card and emits an event with Card's Number
6. Creator gives Card's Number, Claiming Key and Retrieval key to a third party (the Reciever) (This information is presented to the Creator in a formatted text with a link to ether-card.com with Number and Claiming Key pre-entered)
7. Reciever follows a received link or enters Card's Number and Claiming Key manually on the Client and sends it to the Contract
8. Contract checks if Claiming Key is valid and locks the Card to Receiver's address (no one else can retrieve funds from it from now on) (* except for the Creator who can cancel the Card and get his funds including Fee back anytime before it was received)
9. Reciever checks that Card was indeed claimed to his address, enters a Retrieval Key and sends it to the contract
10. Contract checks if Retrieval Key is valid and transfers Card's Value to the Reciever and Card's Fee to a special address specified by Contract's Manager
11. Card's text is presented to the Reciever
12. Card is closed

_Why Claiming Key (and claiming step) is needed? - Claiming key is a defense against malicious nodes that theoretically could fish for a Card's key in order to steal its funds. If a whole chain of actions listed above is executed in a proper order, maximum damage a fisher could do is to lock (claim) a Card to himself with no ability to actually retrieve its funds as he has no Retrieval Key. A receiver could notify Card's Creator to cancel the Card and create a new one. This way it makes no sense (except for vandalic reasons) for anyone to tamper with retrieval process._

*_A Fee is the amount of ether that is transferred to the Contract's creator (me) when Card is retrieved. It calculates beforehand and is added to the transaction at the time of Card's creation. A Fee Rate is_ **0.353236%** _of a Card's Value._

## Developer notes
* To run tests a minimum required c++ compiler version is 4.8
    * https://github.com/trufflesuite/ganache-cli/issues/134
    * To solve an error (on Ubuntu) use https://gist.github.com/omnus/6404505 before installing dependencies
