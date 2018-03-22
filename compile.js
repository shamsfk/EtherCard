
const path = require('path');
const fs = require('fs');
const solc = require('solc');

const ethercardPath = path.resolve(__dirname, 'contracts', 'ethercard.sol');
const source = fs.readFileSync(ethercardPath, 'utf8');

module.exports = solc.compile(source, 1).contracts[':EtherCard'];