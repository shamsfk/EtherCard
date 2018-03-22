# EtherCard
Ethereum based smart-contract for creating unpersonified cards with monetary value in ETH claimable by third party that is given special key by card's creator.

## What is it for
The main purpose of EtherCard is to create a gift card with some amount of ether to be given to somebody you don't want to ask for their address beforehand or you would like to surprise by presenting a card at some exact moment.

_Prepaid accounts can be and are used for the same purpose, the only value of EtherCard is in the retrival process itself and a specific purpose of it which symbolises a gift._

## How it works
EtherCard Contract works in conjuction with EtherCard Client (https://github.com/shamsfk/EtherCardClient) that is available at https://ether-card.com.

1. Card's Creator specifies an amount of ether that will be attributed to the Card (Card's Value) and a special text message (Card's Text)
2. Using random.org Client generates a pair of random keys (private):
    * Claiming Key
    * Retrival Key
3. Using Claiming Key and Retrival Key (+ Value + Creator's Address) Client generates a new pair of keys (public):
    * Public Claiming Key
    * Public Retrival Key
4. Amount, Fee Amount (_0.35323% * Amount_), Public Claiming Key, Public Retrival Key, Card's Text and Creator's Address forms the Card
5. Card is sent to the Contract, Contract stores the card and emits event with Card's Number
6. Creator gives Card's Number, Claiming Key and Retrival key to a third party (Reciever)
7. Reciever enters Card's Number and Claiming Key on the Client and sends it to the Contract
8. Contract checks if Claiming Key is valid and locks the Card to Reciver's address (no one else can retrieve funds from it from now on) (* except the Creator who can chancel the Card and get his funds including Fee back any time before it was recieved)
9. Reciever checks that Card was indeed claimed to his address and enters a Retrival Key that is sent to the contract
10. Contract checks if Retrival Key is valid and transfers Card's Value to the Reciever and Card's Fee to the special address specified by Contract's Manager
11. Card's text is presented to the Reciever
12. Card is closed

_Why Claiming Key (and claiming step) is needed? - Claiming key is a defense against malicious nodes that theoretically could fish for a Card's key in order to steal it's funds. If a whole chain of actions listed above is executed in a proper order, maximum damage a fisher could do is to lock (claim) a Card to himself with no ability to actually retrieve it's funds as he has no Retrieval Key. Reciver could notify Card's Creator for him to cancel the Card and create a new one. This way it makes no sense (except for vandalic reasons) for anyone to tamper with retrival process._

## What is a fee
A Fee is the amount of ether that is transfered to the Contract's creator (me) when Card is recieved. It calculates beforehand and is added to the transaction at the time of Card's creation. A Fee Rate is **0.35323%** of a Card's Value.
