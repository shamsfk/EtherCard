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

    it('allows a manager to change fee address', async () => {
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
});