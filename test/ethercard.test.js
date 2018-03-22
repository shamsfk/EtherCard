require('events').EventEmitter.prototype._maxListeners = 100;

const assert = require('assert');
const ganache = require('ganache-cli');
const Web3 = require('web3');
const web3 = new Web3(ganache.provider());

const { interface, bytecode } = require('../compile');

let ethercard;
let accounts;

beforeEach(async () => {
  accounts = await web3.eth.getAccounts();

  ethercard = await new web3.eth.Contract(JSON.parse(interface))
    .deploy({ data: bytecode })
    .send({ from: accounts[0], gas: '1000000' });
});

describe('EtherCard Contract', () => {
    it('deploys a contract', () => {
        assert.ok(ethercard.options.address);
    });

    it('allows manager to change fee address', async () => {
        await ethercard.methods.changeFeeAddress(accounts[1]).send({
          from: accounts[0],
        });

        const feeAddress = await ethercard.methods.feeAddress().call({
            from: accounts[0]
        });

        assert.equal(accounts[1], feeAddress);
    });

    it('forbids not a manager to change fee address', async () => {
        var error;
        try {
            await ethercard.methods.changeFeeAddress(accounts[2]).send({
                from: accounts[1],
            });
        }
        catch(err) {
            error = err;
        }
        assert.ok(error);
    });

    it('allows card creation', async () => {
        var value = web3.utils.toWei('1.0', 'ether');
        var fee = web3.utils.toWei('0.1', 'ether');
        var claimKey = web3.utils.sha3(web3.utils.toHex("1") + accounts[0], {encoding:"hex"});
        var retrivalKey = web3.utils.sha3(web3.utils.toHex("2") + accounts[0], {encoding:"hex"});

        await ethercard.methods.createCard(value, fee, claimKey, retrivalKey).send({
            from: accounts[0],
            value: web3.utils.toWei('1.1', 'ether'),
            gas: '1000000'
        });

        const card = await ethercard.methods.cards(0).call({
            from: accounts[0]
        });

        assert.ok(card);
        assert.equal(accounts[0], card.creatorAddress);
        assert.equal(value, card.value);
        assert.equal(fee, card.fee);
        assert.equal(web3.utils.toHex(claimKey), web3.utils.toHex(card.publicClaimKey));
        assert.equal(web3.utils.toHex(retrivalKey), web3.utils.toHex(card.publicRetrivalKey));
    });
});