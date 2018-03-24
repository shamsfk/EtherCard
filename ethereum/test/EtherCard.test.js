require('events').EventEmitter.prototype._maxListeners = 100

const assert = require('assert')
const ganache = require('ganache-cli')
const Web3 = require('web3')
const web3 = new Web3(ganache.provider())

const contract = require('../build/EtherCard.json')

let ethercard
let accounts

beforeEach(async () => {
  accounts = await web3.eth.getAccounts()

  ethercard = await new web3.eth.Contract(JSON.parse(contract.interface))
    .deploy({ data: contract.bytecode })
    .send({ from: accounts[0], gas: '1000000' })
})

const sendValue = '1.1'

var createTestCard = async () => {
  var value = web3.utils.toWei('1.0', 'ether')
  var fee = web3.utils.toWei('0.1', 'ether')

  // Pair of private keys sent to recipient
  var claimKey = web3.utils.sha3(web3.utils.toHex('10'))
  var retrievalKey = web3.utils.sha3(web3.utils.toHex('200'))

  // Pair of public keys kept in contract
  var publicClaimKey = web3.utils.sha3(claimKey, {encoding: 'hex'})
  var publicRetrievalKey = web3.utils.sha3(retrievalKey, {encoding: 'hex'})

  await ethercard.methods.createCard(value, fee, publicClaimKey, publicRetrievalKey).send({
    from: accounts[0],
    value: web3.utils.toWei(sendValue, 'ether'),
    gas: '1000000'
  })

  return {value, fee, publicClaimKey, publicRetrievalKey, claimKey, retrievalKey}
}

/// ////////////////////////////////////////////////////////////////////////////////// TESTS:

describe('EtherCard Contract', () => {
/// //////////////////////////////////////////////////////////// DEPLOYMENT & MANGAMENT
  describe('- deployment and management', () => {
    it('deploys a contract', () => {
      assert.ok(ethercard.options.address)
    })

    it('allows manager to change fee address', async () => {
      await ethercard.methods.changeFeeAddress(accounts[1]).send({
        from: accounts[0]
      })

      const feeAddress = await ethercard.methods.feeAddress().call({
        from: accounts[0]
      })

      assert.equal(accounts[1], feeAddress)
    })

    it('forbids not a manager to change fee address', async () => {
      var error
      try {
        await ethercard.methods.changeFeeAddress(accounts[2]).send({
          from: accounts[1]
        })
        await ethercard.methods.changeFeeAddress(accounts[0]).send({
          from: accounts[1]
        })
      } catch (err) {
        error = err
      }
      assert.ok(error)
    })
  })

  /// //////////////////////////////////////////////////////////// CARD CREATION
  describe('- card creation', () => {
    it('allows card creation', async () => {
      var {value, fee, publicClaimKey, publicRetrievalKey} = await createTestCard()

      const card = await ethercard.methods.cards(0).call({
        from: accounts[0]
      })

      assert.ok(card)
      assert.equal(accounts[0], card.creatorAddress)
      assert.equal(value, card.value)
      assert.equal(fee, card.fee)
      assert.equal(web3.utils.toHex(publicClaimKey), web3.utils.toHex(card.publicClaimKey))
      assert.equal(web3.utils.toHex(publicRetrievalKey), web3.utils.toHex(card.publicRetrievalKey))
    })

    it('transfers value to the contract on card creation', async () => {
      await createTestCard()

      var contractBalance = await web3.eth.getBalance(ethercard.options.address)
      assert.equal(contractBalance, web3.utils.toWei(sendValue, 'ether'))
    })
  })

  /// //////////////////////////////////////////////////////////// CARD CANCELATION
  describe('- card cancelation', () => {
    it('allows creator to cancel card', async () => {
      await createTestCard()

      await ethercard.methods.cancelCard(0).send({
        from: accounts[0]
      })

      var card = await ethercard.methods.cards(0).call({
        from: accounts[0]
      })

      assert.equal(card.status, 3)
    })

    it('forbids not a creator to cancel card', async () => {
      await createTestCard()

      var error
      try {
        await ethercard.methods.cancelCard(0).send({
          from: accounts[1]
        })
      } catch (err) {
        error = err
      }
      assert.ok(error)
    })

    it('sends funds back when card is canceled', async () => {
      await createTestCard()

      var accountBalanceBefore = await web3.eth.getBalance(accounts[0])

      await ethercard.methods.cancelCard(0).send({
        from: accounts[0]
      })

      // contract should have no ether
      var contractBalance = await web3.eth.getBalance(ethercard.options.address)
      assert.equal(contractBalance, 0)

      var accountBalanceAfter = await web3.eth.getBalance(accounts[0])

      // creator's balance after cancelation must be bigger than before
      assert.ok(accountBalanceAfter > accountBalanceBefore)
    })
  })
  /// //////////////////////////////////////////////////////////// CARD CLAIMING
  describe('- card claiming', () => {
    it('allows card claiming', async () => {
      var {claimKey} = await createTestCard()

      await ethercard.methods.claimCard(0, claimKey).send({
        from: accounts[1]
      })

      const card = await ethercard.methods.cards(0).call({
        from: accounts[1]
      })

      assert.equal(card.status, 1)
      assert.equal(card.claimerAddress, accounts[1])
    })

    it('isCardClaimedByMe works as intended', async () => {
      var {claimKey} = await createTestCard()

      await ethercard.methods.claimCard(0, claimKey).send({
        from: accounts[1]
      })

      var isClaimed = await ethercard.methods.isCardClaimedByMe(0).call({
        from: accounts[1]
      })
      assert.ok(isClaimed)

      isClaimed = await ethercard.methods.isCardClaimedByMe(0).call({
        from: accounts[0]
      })
      assert.ok(!isClaimed)
    })
  })
  /// //////////////////////////////////////////////////////////// CARD RETRIEVAL
  describe('- card retrieval', () => {
    it('allows card retrieving', async () => {
      var {claimKey, retrievalKey} = await createTestCard()

      await ethercard.methods.claimCard(0, claimKey).send({
        from: accounts[1]
      })

      await ethercard.methods.retrieveCard(0, retrievalKey).send({
        from: accounts[1]
      })

      const card = await ethercard.methods.cards(0).call({
        from: accounts[1]
      })

      assert.equal(card.status, 2)

      // contract should have no ether
      var contractBalance = await web3.eth.getBalance(ethercard.options.address)
      assert.equal(contractBalance, 0)
    })

    it('forbids card retrieving for not a claimer', async () => {
      var {claimKey, retrievalKey} = await createTestCard()

      await ethercard.methods.claimCard(0, claimKey).send({
        from: accounts[1]
      })

      var error
      try {
        await ethercard.methods.retrieveCard(0, retrievalKey).send({
          from: accounts[0]
        })
      } catch (err) {
        error = err
      }
      assert.ok(error)
    })

    it('transfers value on retrieving', async () => {
      var {claimKey, retrievalKey} = await createTestCard()

      await ethercard.methods.claimCard(0, claimKey).send({
        from: accounts[1]
      })

      var accountBalanceBefore = await web3.eth.getBalance(accounts[1])

      await ethercard.methods.retrieveCard(0, retrievalKey).send({
        from: accounts[1]
      })

      var accountBalanceAfter = await web3.eth.getBalance(accounts[1])

      // creator's balance after cancelation must be bigger than before
      assert.ok(accountBalanceAfter > accountBalanceBefore)
    })

    it('transfers fee on retrieving', async () => {
      var {claimKey, retrievalKey} = await createTestCard()

      await ethercard.methods.claimCard(0, claimKey).send({
        from: accounts[1]
      })

      var accountBalanceBefore = await web3.eth.getBalance(accounts[0])

      await ethercard.methods.retrieveCard(0, retrievalKey).send({
        from: accounts[1]
      })

      var accountBalanceAfter = await web3.eth.getBalance(accounts[0])

      // fee balance after cancelation must be bigger than before
      assert.ok(accountBalanceAfter > accountBalanceBefore)
    })
  })
/// ////////////////////////////////////////////////////////////
// TODO: add end to end test
})
